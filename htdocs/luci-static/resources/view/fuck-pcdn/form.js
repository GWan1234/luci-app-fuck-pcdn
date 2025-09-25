'use strict';
'require view';
'require form';
'require rpc';
'require uci';
'require ui';

var callFuckPcdn = rpc.declare({
	object: 'luci.fuck-pcdn',
	method: 'apply_settings',
	params: ['config']
});

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('fuck-pcdn')
		]);
	},

	render: function(data) {
		var m, s, o;

		m = new form.Map('fuck-pcdn', _('PCDN屏蔽器'), 
			_('屏蔽主流视频和音乐平台的PCDN域名，强制使用原始CDN'));

		s = m.section(form.TypedSection, 'settings', _('基本设置'));
		s.anonymous = true;
		s.addremove = false;

		o = s.option(form.Flag, 'enabled', _('启用插件'), 
			_('启用或禁用PCDN屏蔽功能'));
		o.default = '0';

		s = m.section(form.TypedSection, 'platform', _('屏蔽列表'));
		s.anonymous = true;
		s.addremove = false;

		o = s.option(form.Flag, 'qq_music', _('QQ音乐'), 
			_('屏蔽QQ音乐的PCDN域名'));
		o.default = '0';

		o = s.option(form.Flag, 'tencent_video', _('腾讯视频'), 
			_('屏蔽腾讯视频的PCDN域名'));
		o.default = '0';

		o = s.option(form.Flag, 'iqiyi', _('爱奇艺'), 
			_('屏蔽爱奇艺的PCDN域名'));
		o.default = '0';

		o = s.option(form.Flag, 'youku', _('优酷视频'), 
			_('屏蔽优酷视频的PCDN域名'));
		o.default = '0';

		o = s.option(form.Flag, 'bilibili', _('Bilibili'), 
			_('屏蔽Bilibili的PCDN域名'));
		o.default = '0';

		return m.render();
	},

	handleSave: function() {
		var self = this;
		return form.Map.prototype.handleSave.apply(this, arguments).then(function() {
			// 获取当前配置
			var config = {
				enabled: uci.get('fuck-pcdn', 'settings', 'enabled') || '0',
				platforms: {
					qq_music: uci.get('fuck-pcdn', 'platform', 'qq_music') || '0',
					tencent_video: uci.get('fuck-pcdn', 'platform', 'tencent_video') || '0',
					iqiyi: uci.get('fuck-pcdn', 'platform', 'iqiyi') || '0',
					youku: uci.get('fuck-pcdn', 'platform', 'youku') || '0',
					bilibili: uci.get('fuck-pcdn', 'platform', 'bilibili') || '0'
				}
			};

			// 调用后端应用设置
			return callFuckPcdn(config).then(function(result) {
				if (result && result.success) {
					ui.addNotification(null, E('p', _('设置已应用成功')), 'info');
				} else {
					ui.addNotification(null, E('p', _('应用设置时出现错误: ') + (result.error || _('未知错误'))), 'error');
				}
			}).catch(function(err) {
				ui.addNotification(null, E('p', _('应用设置失败: ') + err.message), 'error');
			});
		});
	}
});
