#!/bin/bash

 aws ecr get-login-password --region ap-southeast-1 | kubectl create secret docker-registry ecr-secret --docker-server=xxxxxxxx.dkr.ecr.ap-southeast-1.amazonaws.com --docker-username=AWS --docker-password="$(aws ecr get-login-password --region ap-southeast-1)" --docker-email=none -n dev
