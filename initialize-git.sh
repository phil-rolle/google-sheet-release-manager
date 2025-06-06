#!/usr/bin/env bash

eval "$(ssh-agent -s)"
ssh-add /home/phil/.ssh/github
ssh -T git@github.com
