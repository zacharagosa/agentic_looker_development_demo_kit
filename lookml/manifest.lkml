project_name: "telecom_network_analytics"

# NOTE: Custom visualizations for this project are registered INSTANCE-WIDE via the
# Admin > Visualizations panel (/api/4.0/vis_manifest). Registering them here as well
# created duplicate `looker.plugins.visualizations.add()` calls for the same viz id,
# and the project-scoped (un-versioned, browser-cached) bundle would silently override
# the freshly deployed instance-wide bundle. Do not re-add visualization blocks here.
