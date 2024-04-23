# Grabbed from github:musnix/musnix
# Copyright (c) 2014-2024, Henry Till, Bart Brouns

# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:

# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.

# 3. Neither the names of the copyright holders nor the names of their
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

{pkgs, fetchPypi, ... }:

pkgs.python3.pkgs.buildPythonApplication rec {
    pname = "rtcqs";
    version = "0.6.2";
    format = "pyproject";

    # Dont check that the gui portion of the rtcqs package (rtcqs_gui) can be
    # run. It uses PySimpleGUI, which, though it is available in nixpkgs,
    # doesn't work properly.  It is a deliberately obfuscated commercial
    # library, and isn't readily fixable.  rtcqs_gui offers no functionality
    # that isn't offered by the command-line utility rtcqs.
    #
    # We set 'pythonRuntimeDepsCheck = "true"' in order to skip the Nix
    # dependency checking that causes it to find a dependency on PySimpleGUI
    # (run the UNIX "true" command rather than the default command), making
    # the build complete rather than erroring out.
    pythonRuntimeDepsCheckHook = "true";

    buildInputs = [
      pkgs.python3.pkgs.setuptools
    ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-DfeV9kGhdMf6hZ1iNJ0L3HUn7m8c1gRK5cjtJNUAvJI=";
    };
}