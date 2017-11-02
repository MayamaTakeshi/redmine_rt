#!/bin/bash


mkdir -p log/nginx
mkdir -p run

sudo nginx -p . -c ./nginx.conf 

