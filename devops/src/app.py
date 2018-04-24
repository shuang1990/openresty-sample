#!/usr/bin/env python
# -*- coding:utf-8 -*-

import yaml
import os
import argparse
from jinja2 import Template


class Config(object):
    def __init__(self, template_file=''):
        self.template_file = template_file
        self.target_dir = os.path.dirname(self.template_file)
        current_dir = os.path.dirname(__file__)
        base_dir = os.path.dirname(current_dir)
        config_file = os.path.join(os.path.dirname(current_dir),'conf', 'env.yml')
        self.config_data = self._load_yaml(config_file)
        self.config_data['base_dir'] = os.path.dirname(base_dir)

    def _load_yaml(self, file):
        data = None
        with open(file, 'r') as f:
            data = yaml.load(f)
        return data

    def render_str(self):
        with open(self.template_file, 'r') as f:
            content = f.read()
            self.config_data['dns_servers'] = " ".join(self.config_data['dns_servers'])
            template = Template(content)
            val = template.render(self.config_data)
            return val

    def save_config(self, content):
        config_file = os.path.join(self.target_dir, 'nginx.conf')
        with open(config_file, 'w+') as f:
            f.write(content)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--init-config', metavar=('[nginx template config]'), nargs=1, required=False)

    args = parser.parse_args()

    # 配置解析
    if args.init_config:
        config = Config(args.init_config[0])
        content = config.render_str()
        config.save_config(content)