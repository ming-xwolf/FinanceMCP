#!/usr/bin/env node
/**
 * MCP测试客户端
 * 用于测试FinanceMCP服务器的连接和工具获取
 */

import http from 'http';

// 配置
const CONFIG = {
  serverUrl: 'http://127.0.0.1:8000/mcp',
  headers: {
    'Content-Type': 'application/json',
    'X-Tushare-Token': 'f11798770f32be905122f11c537f7e622f187a233d47c815b58d37b7'
  }
};

// 发送HTTP请求的辅助函数
function sendRequest(method, params = {}) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      jsonrpc: '2.0',
      id: Date.now(),
      method: method,
      params: params
    });

    const options = {
      hostname: '127.0.0.1',
      port: 8000,
      path: '/mcp',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'X-Tushare-Token': CONFIG.headers['X-Tushare-Token']
      }
    };

    console.log(`📤 发送请求: ${method}`);
    console.log(`📦 请求数据:`, JSON.stringify(JSON.parse(postData), null, 2));

    const req = http.request(options, (res) => {
      console.log(`📡 响应状态: ${res.statusCode}`);
      console.log(`📋 响应头:`, res.headers);

      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log(`📥 响应数据:`, JSON.stringify(response, null, 2));
          resolve(response);
        } catch (error) {
          console.error(`❌ 解析响应失败:`, error);
          console.log(`📄 原始响应:`, data);
          reject(error);
        }
      });
    });

    req.on('error', (error) => {
      console.error(`❌ 请求失败:`, error);
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// 测试健康检查
async function testHealth() {
  console.log('\n🏥 测试健康检查...');
  try {
    const response = await fetch('http://127.0.0.1:8000/health');
    const data = await response.json();
    console.log('✅ 健康检查成功:', data);
    return true;
  } catch (error) {
    console.error('❌ 健康检查失败:', error);
    return false;
  }
}

// 测试工具列表获取
async function testToolsList() {
  console.log('\n🛠️ 测试工具列表获取...');
  try {
    const response = await sendRequest('tools/list');
    
    if (response.result && response.result.tools) {
      console.log(`✅ 成功获取 ${response.result.tools.length} 个工具:`);
      response.result.tools.forEach((tool, index) => {
        console.log(`  ${index + 1}. ${tool.name}: ${tool.description}`);
      });
      return true;
    } else {
      console.error('❌ 响应格式错误:', response);
      return false;
    }
  } catch (error) {
    console.error('❌ 获取工具列表失败:', error);
    return false;
  }
}

// 测试工具调用
async function testToolCall() {
  console.log('\n🔧 测试工具调用...');
  try {
    const response = await sendRequest('tools/call', {
      name: 'current_timestamp',
      arguments: {
        format: 'datetime'
      }
    });
    
    if (response.result) {
      console.log('✅ 工具调用成功:', response.result);
      return true;
    } else {
      console.error('❌ 工具调用失败:', response);
      return false;
    }
  } catch (error) {
    console.error('❌ 工具调用异常:', error);
    return false;
  }
}

// 主测试函数
async function runTests() {
  console.log('🚀 开始MCP客户端测试...\n');
  
  // 测试健康检查
  const healthOk = await testHealth();
  if (!healthOk) {
    console.log('\n❌ 服务器健康检查失败，请确保服务器正在运行');
    process.exit(1);
  }
  
  // 测试工具列表
  const toolsOk = await testToolsList();
  if (!toolsOk) {
    console.log('\n❌ 工具列表获取失败');
    process.exit(1);
  }
  
  // 测试工具调用
  const callOk = await testToolCall();
  if (!callOk) {
    console.log('\n❌ 工具调用失败');
    process.exit(1);
  }
  
  console.log('\n🎉 所有测试通过！MCP服务器工作正常');
}

// 运行测试
runTests().catch(error => {
  console.error('\n💥 测试运行失败:', error);
  process.exit(1);
});
