
local argo = import 'kubernetes/argo.libsonnet';
local ok = import 'kubernetes/outreach.libsonnet';
local app = (import 'kubernetes/app.libsonnet').info('rabbitmq-cluster-operator');

local version = std.extVar('version_%s' % app.name);

// <<Stencil::Block(extraJsonnetImports)>>

// <</Stencil::Block>>

local all() = {
  app: argo.ArgoCDApplication(app, 'stencil-pipeline') {
    repo_name_:: 'rabbitmq-cluster-operator',
    source_path_:: '.',
    manifest_path_:: 'rabbitmq-cluster-operator.jsonnet',
    namespace_:: 'rabbitmq-cluster-operator',
    version_:: version,
    env_:: {
      // <<Stencil::Block(extraEnvironmentVariables)>>
      
      // <</Stencil::Block>>
    },
    slack_:: '#qss-notifications',
  },
};

ok.List() { items_+: all() }