-- Created by IntelliJ IDEA.
-- User: ys
-- Date: 12/02/2018
-- Time: 1:16 PM
local check = require "check"
local send =  require "send"
local utils = require "utils"

-- 获取请求相关数据
local utils_obj = utils:new()
local request_args, method = utils_obj:get_request_info()
local token = utils_obj:get_token(request_args)
local api = utils_obj:get_api()
local api_desc = utils_obj:get_api_desc(api)
local client = request_args["client"]
local domain = request_args["domain"]

-- 验证token格式
local check_obj = check:new()
check_obj:check_login_and_token(token, api, api_desc)
check_obj:check_client(client)
check_obj:check_domain(domain)

-- 获取代理uri
local proxy_url = utils_obj:format_proxy_uri(client, domain, api)
local accpet = utils_obj:get_request_headers()["Accept"]

-- 发送请求
local send_obj = send:new()
send_obj:send_request(request_args, proxy_url, method, accept)