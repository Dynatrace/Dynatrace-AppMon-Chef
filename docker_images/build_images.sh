#!/bin/sh

# Create images with preinstalled chef components to speed up kitchen test execution
docker build -t centos-6-chef centos-6-chef
docker build -t debian-7.8-chef debian-7.8-chef
docker build -t ubuntu-12.04-chef ubuntu-12.04-chef
