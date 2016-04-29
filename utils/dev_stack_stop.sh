#!/usr/bin/env bash

kill -9 `ps aux | grep -v grep | grep glance | awk '{print $2}'`
kill -9 `ps aux | grep -v grep | grep keystone | awk '{print $2}'`
kill -9 `ps aux | grep -v grep | grep -v dnsmasq | grep nova- | awk '{print $2}'`

