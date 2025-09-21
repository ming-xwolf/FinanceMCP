#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema, } from "@modelcontextprotocol/sdk/types.js";
// ✅ 引入你自定义的财经工具
import { financeNews } from "./tools/financeNews.js";
import { stockData } from "./tools/stockData.js";
import { indexData } from "./tools/indexData.js";
import { macroEcon } from "./tools/macroEcon.js";
import { companyPerformance } from "./tools/companyPerformance.js";
import { fundData } from "./tools/fundData.js";
import { fundManagerByName, runFundManagerByName } from "./tools/fundManagerByName.js";
import { convertibleBond } from "./tools/convertibleBond.js";
import { blockTrade } from "./tools/blockTrade.js";
import { moneyFlow } from "./tools/moneyFlow.js";
import { marginTrade } from "./tools/marginTrade.js";
import { companyPerformance_hk } from "./tools/companyPerformance_hk.js";
import { companyPerformance_us } from "./tools/companyPerformance_us.js";
import { csiIndexConstituents } from "./tools/csiIndexConstituents.js";
import { dragonTigerInst } from "./tools/dragonTigerInst.js";
import { hotNews } from "./tools/hotNews.js";
// 🕐 时间戳工具定义
const timestampTool = {
    name: "current_timestamp",
    description: "获取当前东八区（中国时区）的时间戳，包括年月日时分秒信息",
    parameters: {
        type: "object",
        properties: {
            format: {
                type: "string",
                description: "时间格式，可选值：datetime(完整日期时间，默认)、date(仅日期)、time(仅时间)、timestamp(Unix时间戳)、readable(可读格式)"
            }
        }
    },
    async run(args) {
        try {
            // 获取当前UTC时间
            const now = new Date();
            // 转换为东八区时间（UTC+8）
            const chinaTime = new Date(now.getTime() + (8 * 60 * 60 * 1000));
            const format = args?.format || 'datetime';
            // 格式化时间函数
            const formatNumber = (num) => num.toString().padStart(2, '0');
            const year = chinaTime.getUTCFullYear();
            const month = formatNumber(chinaTime.getUTCMonth() + 1);
            const day = formatNumber(chinaTime.getUTCDate());
            const hour = formatNumber(chinaTime.getUTCHours());
            const minute = formatNumber(chinaTime.getUTCMinutes());
            const second = formatNumber(chinaTime.getUTCSeconds());
            // 星期几
            const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
            const weekday = weekdays[chinaTime.getUTCDay()];
            let result;
            switch (format) {
                case 'date':
                    result = `${year}-${month}-${day}`;
                    break;
                case 'time':
                    result = `${hour}:${minute}:${second}`;
                    break;
                case 'timestamp':
                    result = Math.floor(chinaTime.getTime() / 1000).toString();
                    break;
                case 'readable':
                    result = `${year}年${month}月${day}日 ${weekday} ${hour}时${minute}分${second}秒`;
                    break;
                case 'datetime':
                default:
                    result = `${year}-${month}-${day} ${hour}:${minute}:${second}`;
                    break;
            }
            return {
                content: [
                    {
                        type: "text",
                        text: `## 🕐 当前东八区时间\n\n格式: ${format}\n时间: ${result}\n\n时区: 东八区 (UTC+8)\n星期: ${weekday}\n\n---\n\n*时间戳获取于: ${year}-${month}-${day} ${hour}:${minute}:${second}*`
                    }
                ]
            };
        }
        catch (error) {
            return {
                content: [
                    {
                        type: "text",
                        text: `❌ 获取时间戳时发生错误: ${error instanceof Error ? error.message : String(error)}`
                    }
                ],
                isError: true
            };
        }
    }
};
// 创建 MCP server
const server = new Server({
    name: "FinanceMCP",
    version: "1.0.0",
}, {
    capabilities: {
        tools: {},
    },
});
// 🛠️ 工具：列出财经分析工具
server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: timestampTool.name,
                description: timestampTool.description,
                inputSchema: timestampTool.parameters
            },
            {
                name: financeNews.name,
                description: financeNews.description,
                inputSchema: financeNews.parameters
            },
            {
                name: stockData.name,
                description: stockData.description,
                inputSchema: stockData.parameters
            },
            {
                name: indexData.name,
                description: indexData.description,
                inputSchema: indexData.parameters
            },
            {
                name: macroEcon.name,
                description: macroEcon.description,
                inputSchema: macroEcon.parameters
            },
            {
                name: companyPerformance.name,
                description: companyPerformance.description,
                inputSchema: companyPerformance.parameters
            },
            {
                name: fundData.name,
                description: fundData.description,
                inputSchema: fundData.parameters
            },
            {
                name: fundManagerByName.name,
                description: fundManagerByName.description,
                inputSchema: fundManagerByName.inputSchema
            },
            {
                name: convertibleBond.name,
                description: convertibleBond.description,
                inputSchema: convertibleBond.parameters
            },
            {
                name: blockTrade.name,
                description: blockTrade.description,
                inputSchema: blockTrade.parameters
            },
            {
                name: moneyFlow.name,
                description: moneyFlow.description,
                inputSchema: moneyFlow.parameters
            },
            {
                name: marginTrade.name,
                description: marginTrade.description,
                inputSchema: marginTrade.parameters
            },
            {
                name: companyPerformance_hk.name,
                description: companyPerformance_hk.description,
                inputSchema: companyPerformance_hk.parameters
            },
            {
                name: companyPerformance_us.name,
                description: companyPerformance_us.description,
                inputSchema: companyPerformance_us.parameters
            },
            {
                name: csiIndexConstituents.name,
                description: csiIndexConstituents.description,
                inputSchema: csiIndexConstituents.parameters
            },
            {
                name: dragonTigerInst.name,
                description: dragonTigerInst.description,
                inputSchema: dragonTigerInst.parameters
            },
            {
                name: hotNews.name,
                description: hotNews.description,
                inputSchema: hotNews.parameters
            }
        ]
    };
});
// 🛠️ 工具：执行工具
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    switch (request.params.name) {
        case "current_timestamp": {
            const format = request.params.arguments?.format ? String(request.params.arguments.format) : undefined;
            return await timestampTool.run({ format });
        }
        case "finance_news": {
            const query = String(request.params.arguments?.query);
            return await financeNews.run({ query });
        }
        case "stock_data": {
            const code = String(request.params.arguments?.code);
            const market_type = String(request.params.arguments?.market_type);
            const start_date = request.params.arguments?.start_date ? String(request.params.arguments.start_date) : undefined;
            const end_date = request.params.arguments?.end_date ? String(request.params.arguments.end_date) : undefined;
            const indicators = request.params.arguments?.indicators ? String(request.params.arguments.indicators) : undefined;
            return await stockData.run({ code, market_type, start_date, end_date, indicators });
        }
        case "index_data": {
            const code = String(request.params.arguments?.code);
            const start_date = request.params.arguments?.start_date ? String(request.params.arguments.start_date) : undefined;
            const end_date = request.params.arguments?.end_date ? String(request.params.arguments.end_date) : undefined;
            return await indexData.run({ code, start_date, end_date });
        }
        case "macro_econ": {
            const indicator = String(request.params.arguments?.indicator);
            const start_date = request.params.arguments?.start_date ? String(request.params.arguments.start_date) : undefined;
            const end_date = request.params.arguments?.end_date ? String(request.params.arguments.end_date) : undefined;
            return await macroEcon.run({ indicator, start_date, end_date });
        }
        case "company_performance": {
            const ts_code = String(request.params.arguments?.ts_code);
            const data_type = String(request.params.arguments?.data_type);
            const start_date = String(request.params.arguments?.start_date);
            const end_date = String(request.params.arguments?.end_date);
            const period = request.params.arguments?.period ? String(request.params.arguments.period) : undefined;
            return await companyPerformance.run({ ts_code, data_type, start_date, end_date, period });
        }
        case "fund_data": {
            const ts_code = request.params.arguments?.ts_code ? String(request.params.arguments.ts_code) : undefined;
            const data_type = String(request.params.arguments?.data_type);
            const start_date = request.params.arguments?.start_date ? String(request.params.arguments.start_date) : undefined;
            const end_date = request.params.arguments?.end_date ? String(request.params.arguments.end_date) : undefined;
            const period = request.params.arguments?.period ? String(request.params.arguments.period) : undefined;
            return await fundData.run({ ts_code, data_type, start_date, end_date, period });
        }
        case "fund_manager_by_name": {
            const name = String(request.params.arguments?.name);
            const ann_date = request.params.arguments?.ann_date ? String(request.params.arguments.ann_date) : undefined;
            return await runFundManagerByName({ name, ann_date });
        }
        case "convertible_bond": {
            const ts_code = request.params.arguments?.ts_code ? String(request.params.arguments.ts_code) : undefined;
            const data_type = String(request.params.arguments?.data_type);
            const start_date = request.params.arguments?.start_date ? String(request.params.arguments.start_date) : undefined;
            const end_date = request.params.arguments?.end_date ? String(request.params.arguments.end_date) : undefined;
            return await convertibleBond.run({ ts_code, data_type, start_date, end_date });
        }
        case "block_trade": {
            const code = request.params.arguments?.code ? String(request.params.arguments.code) : undefined;
            const start_date = String(request.params.arguments?.start_date);
            const end_date = String(request.params.arguments?.end_date);
            return await blockTrade.run({ code, start_date, end_date });
        }
        case "money_flow": {
            const ts_code = request.params.arguments?.ts_code ? String(request.params.arguments.ts_code) : undefined;
            const start_date = String(request.params.arguments?.start_date);
            const end_date = String(request.params.arguments?.end_date);
            return await moneyFlow.run({ ts_code, start_date, end_date });
        }
        case "margin_trade": {
            const data_type = String(request.params.arguments?.data_type);
            const ts_code = request.params.arguments?.ts_code ? String(request.params.arguments.ts_code) : undefined;
            const start_date = String(request.params.arguments?.start_date);
            const end_date = request.params.arguments?.end_date ? String(request.params.arguments.end_date) : undefined;
            const exchange = request.params.arguments?.exchange ? String(request.params.arguments.exchange) : undefined;
            return await marginTrade.run({ data_type, ts_code, start_date, end_date, exchange });
        }
        case "company_performance_hk": {
            const ts_code = String(request.params.arguments?.ts_code);
            const data_type = String(request.params.arguments?.data_type);
            const start_date = String(request.params.arguments?.start_date);
            const end_date = String(request.params.arguments?.end_date);
            const period = request.params.arguments?.period ? String(request.params.arguments.period) : undefined;
            const ind_name = request.params.arguments?.ind_name ? String(request.params.arguments.ind_name) : undefined;
            return await companyPerformance_hk.run({ ts_code, data_type, start_date, end_date, period, ind_name });
        }
        case "company_performance_us": {
            const ts_code = String(request.params.arguments?.ts_code);
            const data_type = String(request.params.arguments?.data_type);
            const start_date = String(request.params.arguments?.start_date);
            const end_date = String(request.params.arguments?.end_date);
            const period = request.params.arguments?.period ? String(request.params.arguments.period) : undefined;
            return await companyPerformance_us.run({ ts_code, data_type, start_date, end_date, period });
        }
        case "csi_index_constituents": {
            const index_code = String(request.params.arguments?.index_code);
            const start_date = String(request.params.arguments?.start_date);
            const end_date = String(request.params.arguments?.end_date);
            return await csiIndexConstituents.run({ index_code, start_date, end_date });
        }
        case "dragon_tiger_inst": {
            const trade_date = String(request.params.arguments?.trade_date);
            const ts_code = request.params.arguments?.ts_code ? String(request.params.arguments.ts_code) : undefined;
            return await dragonTigerInst.run({ trade_date, ts_code });
        }
        case "hot_news_7x24": {
            return await hotNews.run({});
        }
        default:
            throw new Error("Unknown tool");
    }
});
// 启动 server
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
}
main().catch((error) => {
    console.error("Server error:", error);
    process.exit(1);
});
