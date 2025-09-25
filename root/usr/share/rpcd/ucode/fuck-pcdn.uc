#!/usr/bin/ucode

'use strict';

import { access, open, readfile, writefile } from 'fs';
import { connect } from 'ubus';
import { cursor } from 'uci';

const ubus = connect();
const uci = cursor();

// 域名映射配置 - 从指定的在线 JSON 文件获取域名列表
const DOMAIN_API_URL = "https://pikachuim.github.io/luci-app-fuck-pcdn/banlist.json";
const HOSTS_FILE = "/etc/hosts";
const HOSTS_BACKUP = "/etc/hosts.fuck-pcdn.bak";

// 平台域名映射（如果 API 不可用时的备用域名）
const PLATFORM_DOMAINS = {
	qq_music: [
		"musicps.p2p.qq.com",
		"p.tencentmusic.com",
		"twns.p2ptun.qq.com",
		"p2p.music.qq.com",
		"ws.stream.qqmusic.qq.com"
	],
	tencent_video: [
		"p2p.video.qq.com",
		"livep2p.video.qq.com",
		"btrace.video.qq.com",
		"vd.l.qq.com",
		"livew.l.qq.com"
	],
	iqiyi: [
		"p2p.iqiyi.com",
		"p2p-live.iqiyi.com",
		"msg.71.am",
		"msg.qy.net",
		"cupid.iqiyi.com"
	],
	youku: [
		"p2p.youku.com",
		"p2p-live.youku.com",
		"hudong.pl.youku.com",
		"lstat.youku.com",
		"atm.youku.com"
	],
	bilibili: [
		"p2p.biliapi.net",
		"p2p.bilibili.com",
		"livep2p.bilibili.com",
		"data.bilibili.com",
		"cm.bilibili.com"
	]
};

// 获取域名列表
function getDomains(platform) {
	// 首先尝试从在线 API 获取最新域名列表
	try {
		let cmd = sprintf("curl -s --connect-timeout 10 --max-time 30 '%s'", DOMAIN_API_URL);
		let result = system(cmd, true);
		
		if (result.code === 0 && result.stdout) {
			let data = json(result.stdout);
			if (data && data[platform] && length(data[platform]) > 0) {
				// 成功从在线 API 获取域名列表
				return data[platform];
			}
		}
	} catch (e) {
		// API 获取失败，记录错误但继续使用备用域名
		warn(sprintf("Failed to fetch domains from API: %s", e));
	}
	
	// 使用本地备用域名列表
	return PLATFORM_DOMAINS[platform] || [];
}

// 读取 hosts 文件
function readHosts() {
	try {
		return readfile(HOSTS_FILE) || "";
	} catch (e) {
		return "";
	}
}

// 写入 hosts 文件
function writeHosts(content) {
	try {
		// 备份原文件
		let original = readHosts();
		writefile(HOSTS_BACKUP, original);
		
		// 写入新内容
		writefile(HOSTS_FILE, content);
		return true;
	} catch (e) {
		return false;
	}
}

// 清理 hosts 文件中的 PCDN 条目
function cleanHosts(content) {
	let lines = split(content, '\n');
	let cleaned = [];
	
	for (let line in lines) {
		// 跳过包含 PCDN 标记的行
		if (index(line, "# FUCK-PCDN") === -1) {
			push(cleaned, line);
		}
	}
	
	return join(cleaned, '\n');
}

// 添加域名到 hosts
function addDomainsToHosts(content, domains) {
	let lines = split(content, '\n');
	
	// 添加标记注释
	push(lines, "");
	push(lines, "# FUCK-PCDN - Auto generated entries");
	
	// 添加域名条目
	for (let domain in domains) {
		push(lines, sprintf("127.0.0.1 %s # FUCK-PCDN", domain));
	}
	
	push(lines, "# FUCK-PCDN - End");
	
	return join(lines, '\n');
}

// 应用设置
function applySettings(config) {
	try {
		let hostsContent = readHosts();
		
		// 清理现有的 PCDN 条目
		hostsContent = cleanHosts(hostsContent);
		
		// 如果插件启用
		if (config.enabled === '1') {
			let allDomains = [];
			
			// 收集所有需要屏蔽的域名
			for (let platform in config.platforms) {
				if (config.platforms[platform] === '1') {
					let domains = getDomains(platform);
					for (let domain in domains) {
						push(allDomains, domain);
					}
				}
			}
			
			// 添加域名到 hosts
			if (length(allDomains) > 0) {
				hostsContent = addDomainsToHosts(hostsContent, allDomains);
			}
		}
		
		// 写入 hosts 文件
		if (writeHosts(hostsContent)) {
			// 重启 dnsmasq 服务
			system("/etc/init.d/dnsmasq restart");
			
			return {
				success: true,
				message: "设置应用成功"
			};
		} else {
			return {
				success: false,
				error: "写入 hosts 文件失败"
			};
		}
		
	} catch (e) {
		return {
			success: false,
			error: sprintf("应用设置时出错: %s", e)
		};
	}
}

// RPC 方法导出
const methods = {
	apply_settings: {
		args: {
			config: "object"
		},
		call: function(req) {
			return applySettings(req.args.config);
		}
	}
};

return { "luci.fuck-pcdn": methods };