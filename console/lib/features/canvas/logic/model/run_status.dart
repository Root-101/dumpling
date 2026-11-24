/// How the last run of a config went, as the service says it
/// [queued]: waiting for the run of its config in progress to end
enum RunStatus { queued, running, success, failed }
