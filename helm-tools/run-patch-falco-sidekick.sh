#!/bin/bash
helm upgrade --install falcosidekick falcosecurity/falcosidekick \
  -n falco \
  -f values-sidekick.yaml
