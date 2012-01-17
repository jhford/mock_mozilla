#!/bin/bash
sudo rpm -e mock_mozilla
rm noarch/*.rpm
make rpm
sudo rpm -Uvh noarch/mock_mozilla*.rpm
