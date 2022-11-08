# -*- coding: utf-8 -*-
"""
TencentBlueKing is pleased to support the open source community by making
蓝鲸智云 - PaaS 平台 (BlueKing - PaaS System) available.
Copyright (C) 2017 THL A29 Limited,
a Tencent company. All rights reserved.
Licensed under the MIT License (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://opensource.org/licenses/MIT
Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on
an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the
specific language governing permissions and limitations under the License.

We undertake not to change the open source license (MIT license) applicable

to the current version of the project delivered to anyone in the future.
"""
# Generated by Django 1.11.29 on 2020-04-13 09:15
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion
import jsonfield.fields
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('paas_service', '0003_auto_20200102_2209'),
    ]

    operations = [
        migrations.CreateModel(
            name='ServiceInstanceConfig',
            fields=[
                ('uuid', models.UUIDField(auto_created=True, default=uuid.uuid4, editable=False, primary_key=True, serialize=False, unique=True, verbose_name='UUID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('paas_app_info', jsonfield.fields.JSONField(blank=True, default=dict, verbose_name='平台应用信息')),
                ('instance', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to='paas_service.ServiceInstance', verbose_name='服务实例')),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
