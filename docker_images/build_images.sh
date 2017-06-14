#!/bin/sh

# Create images with preinstalled chef components to speed up kitchen test execution
docker build -t centos-7-chef centos-7-chef
docker build -t debian-8.8-chef debian-8.8-chef
docker build -t ubuntu-16.04-chef ubuntu-16.04-chef
