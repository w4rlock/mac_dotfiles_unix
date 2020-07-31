#!/usr/bin/env node

process.env.AWS_REGION = process.env.AWS_REGION || 'us-east-1';

const chalk = require("chalk");
const fs = require("fs");
const url = require("url");
const Aws = require("aws-sdk");
const _ = require("lodash");

const APIGateway = new Aws.APIGateway();
const LOG = console.log;
const cacheDir = `${process.env.HOME}/.tools/domain`;
const cacheApiGatewayImplDir = `${cacheDir}/api-gateway-impl`;
const cacheRestApisFile = `${cacheDir}/rest-apis.json`;
const cacheDomainsFile = `${cacheDir}/domains.json`;

const creds = { region: 'us-east-1' };

const readJsonFile = file => JSON.parse(fs.readFileSync(file));
const writeJsonFile = (f, d) => fs.writeFileSync(f, JSON.stringify(d, null, 2));
const existsFile = dirOrFile => {
  try {
    fs.accessSync(dirOrFile);
    return true;
  } catch (e) {
    return false;
  }
};
const mkdir = dir => {
  if (!existsFile(dir)) fs.mkdirSync(dir);
};

mkdir(cacheDir);
mkdir(cacheApiGatewayImplDir);

async function getRestApis() {
  if (existsFile(cacheRestApisFile)) {
    return readJsonFile(cacheRestApisFile);
  }

  const { items } = await APIGateway.getRestApis().promise();
  writeJsonFile(cacheRestApisFile, items);

  return items;
}

async function getRestApiMethod(restApiId, resourceId, httpMethod) {
  const method = await APIGateway.getMethod({
    restApiId,
    resourceId,
    httpMethod
  }).promise();

  return method;
}

async function getDomains() {
  if (existsFile(cacheDomainsFile)) {
    return readJsonFile(cacheDomainsFile);
  }

  const { items } = await APIGateway.getDomainNames().promise();
  let restsApi = await getRestApis();
  restsApi = _.isEmpty(restsApi) ? [] : restsApi;
  LOG(`Rests apis found: ${restsApi.length}`);
  LOG();

  for (const item of items) {
    let { domainName } = item;
    console.log(`Fetching mappings for domain name '${domainName}'...`);
    let mappings = await getBasePathMappings(domainName);

    if (!_.isEmpty(mappings) && mappings.length > 0) {
      item.mappings = [];

      for (const map of mappings) {
        item.mappings.push({
          stage: map.stage,
          basePath: map.basePath == "(none)" ? "" : map.basePath,
          restApi: restsApi.find(api => api.id == map.restApiId)
        });

        console.log(`${domainName} - ${map.stage} - ${map.restApiId}`);
      }
      LOG();
    }
  }

  writeJsonFile(cacheDomainsFile, items);
  return items;
}

async function getApiGateway(restApi) {
  if (_.isEmpty(restApi)) {
    return Promise.resolve({});
  }

  const { id, name } = restApi;
  const cacheApi = `${cacheApiGatewayImplDir}/${id}-${name}.json`;
  if (existsFile(cacheApi)) {
    return readJsonFile(cacheApi);
  }

  console.log(`Fetching api gateway impl for '${name}'...`);
  const { items } = await APIGateway.getResources({ restApiId: id }).promise();

  let methodDetail = {};
  for (const item of items) {
    item.methods = [];

    if (!_.isEmpty(item.resourceMethods)) {
      for (const method of Object.keys(item.resourceMethods)) {
        if (!_.isEmpty(method)) {
          console.log(`Fetching method impl for '${item.path}'...`);
          methodDetail = await getRestApiMethod(id, item.id, method);
          item.methods.push(methodDetail);
        }
      }
    }
  }

  writeJsonFile(cacheApi, items);

  return items;
}

async function getBasePathMappings(domainName) {
  const { items } = await APIGateway.getBasePathMappings({
    domainName
  }).promise();
  return items;
}

const main = async () => {
  const { yellow, green, grey, blue, red } = chalk;
  const darkRed = chalk.rgb(190, 0, 0);
  let domains = await getDomains();
  let basePath = "";
  let httpMethod = "";
  let methodUrl = "";
  let lastDomain = "";
  let apiPath = "";
  let gaps = "";
  let maxApiPathLength = 0;
  let maxHttpMethodLength = 0;
  let protocol = "";
  let authIcon = "";

  let totalApiGateways = 0;
  let totalApiPath = 0;
  let totalMethods = 0;
  let hasApiAuthorizer = false;

  for (const domain of domains) {
    if (domain.mappings && domain.mappings.length > 0) {
      maxApiPathLength = 0;
      for (const api of domain.mappings) {
        totalApiGateways += 1;
        api.impl = await getApiGateway(api.restApi);
        LOG();
        if (lastDomain !== domain.domainName) {
          LOG();
          LOG();
          LOG(green(`Domain: ${domain.domainName}`));
          lastDomain = domain.domainName;
        }
        if (!api.restApi) {
          continue
        }
          LOG(
            green("ApiGateway: ") +
              yellow(api.restApi.name + green("  Stage: ") + yellow(api.stage)) +
              green("  Id: ") +
              yellow(api.restApi.id)
          );

        basePath = api.basePath ? `/${api.basePath}` : "";
        hasApiAuthorizer = false;
        maxHttpMethodLength = 0;
        for (const impl of api.impl) {
          if (maxApiPathLength < basePath.length + impl.path.length) {
            maxApiPathLength = basePath.length + impl.path.length;
          }
          for (const method of impl.methods) {
            if (maxHttpMethodLength < method.httpMethod.length) {
              maxHttpMethodLength = method.httpMethod.length;
            }
          }
          if (!hasApiAuthorizer) {
            for (const m of impl.methods) {
              if (!_.isEmpty(m.authorizerId)) {
                hasApiAuthorizer = true;
                break;
              }
            }
          }
        }

        for (const impl of api.impl) {
          totalApiPath += 1;

          for (const method of impl.methods) {
            totalMethods += 1;
            if ("DELETE,POST,PUT".indexOf(method.httpMethod) > -1) {
              httpMethod = red.bold(method.httpMethod);
            } else {
              httpMethod = blue.bold(method.httpMethod);
            }

            // align
            if (method.httpMethod.length < maxHttpMethodLength) {
              gaps = " ".repeat(maxHttpMethodLength - method.httpMethod.length);
              httpMethod += gaps;
            }

            if (hasApiAuthorizer) {
              authIcon = "    ";
              if (!_.isEmpty(method.authorizerId)) {
                authIcon = grey(" 廬 ");
              }
            } else {
              authIcon = " ";
            }

            methodUrl = _.get(method, "methodIntegration.uri", "");
            if (!_.isEmpty(methodUrl)) {
              methodUrl = url.parse(methodUrl);
              protocol = methodUrl.protocol;
              if (protocol == "https:") protocol = green(protocol);
              methodUrl = `${protocol}//${methodUrl.host}`;
            }
            methodUrl = grey(methodUrl);

            apiPath = basePath + impl.path;
            apiPath +=
              "  " +
              chalk.rgb(40, 40, 40)(
                "─".repeat(maxApiPathLength + 2 - apiPath.length)
              );
            apiPath =
              grey(apiPath.substr(0, apiPath.lastIndexOf("/"))) +
              apiPath.substr(apiPath.lastIndexOf("/"));

            LOG(
              `${grey("├─")}${authIcon}${httpMethod}   ${apiPath} ${red(
                ""
              )} ${methodUrl}`
            );
          }
        }
      }
    }
  }

  LOG();
  LOG(green(`Domains: ${domains.length}`));
  LOG(green(`Api Gateways: ${totalApiGateways}`));
  LOG(green(`Apis Path: ${totalApiPath}`));
  LOG(green(`Apis Methods: ${totalMethods}`));
  LOG();
};

main();