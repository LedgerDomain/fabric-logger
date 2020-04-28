#!/usr/bin/env python3

from plumbum import local, cli, FG, BG
import time

class SplunkControl(cli.Application):

    def main(self):
        if not self.nested_command:
            print("No command given")
            return 1

@SplunkControl.subcommand("fabric-logger")
class FabricCollectorControl(cli.Application):
    DESCRIPTION = "Run or reset fabric=logger: cmd={'run', 'reset'}"

    _run_logger_cmd = local["./run-fabric-logger.sh"]
    _gen_network_yaml_cmd = local["./gen-network-yaml.sh" ]
    _rm_checkpoints_cmd =  local["rm"]["../.checkpoints"]
    _start_collection_cmd = local["curl"]["http://localhost:8080/channels/simple-channel"]

    _output_location = "../fabric-logger-output.log"

    @cli.switch("--output-file", str)
    def output_file(self, fname):
        self._output_location = fname

    def reset(self):
        print("Generating network.yaml and removing .checkpoints file")
        self._gen_network_yaml_cmd()
        try:
            self._rm_checkpoints_cmd()
        except:
            pass

    def run_(self):
        output_location = self._output_location
        print(f"redirecting output to {output_location}")
        self._run_logger_cmd[output_location] & BG

    def main(self, cmd):
        if cmd == "run":
            print("Starting logger")
            self.run_()
            time.sleep(2)
            print("Requesting collection from channel")
            self._start_collection_cmd()
        elif cmd == "reset":
            self.reset()


@SplunkControl.subcommand("peerlog")
class PeerLoggingControl(cli.Application):

    def _restart_splunk(self):
        local["/opt/splunkforwarder/bin/splunk"]["restart"] & FG

    @cli.switch("--enable", excludes=["--disable"])
    def peerlog(self):
        print("Enabling peer log")
        local["./enable-peer-logs.sh"]()
        self._restart_splunk()

    @cli.switch("--disable", excludes=["--enable"])
    def disable(self):
        print("Disabling peer log")
        local["./disable-peer-logs.sh"]()
        self._restart_splunk()

    def main(self):
        pass


if __name__ == '__main__':
    SplunkControl.run()
