{pkgs, ...}: {
  minecraftMods = {
    minecraftTransitRailway = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/XKPAmI6u/versions/PP5puu9Z/MTR-forge-1.19.4-3.2.2-hotfix-1.jar";
      sha512 = "ebd61018b4e9adc6fd097965b5dadc688415d688b0ddeddd2ba21457da3f0104d5fff161373df1a2bb76fc1c458f39f20dce9ab8bf44bc7ac35a30f5f9d49442";
    };
    stationDecoration = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/AM3NyLOZ/versions/uckw2Zw0/MTR-MSD-Addon-fabric-1.19.4-3.2.2-1.3.4-enhancement-1.jar";
      sha512 = "63047bc0b7168888a2cecad59f352b02ad07153566ed3f6227728aaf25f50617afc65b91a4464cfda799204e56e30d239468b1a9261272279c59e6fde24a292d";
    };

    # MTR dependency
    fabricAPI = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/uIYkhRbX/fabric-api-0.86.1%2B1.19.4.jar";
      sha512 = "5e69f86026180244508ef4941433cb2b5821463e3e5d7f85a2eadb976a03b1ca25e6edc3337aa9d34ef6ed96e07cdf8f5a00261a97798afe08263ca692546c0d";
    };

    # Game logic optimiazations
    lithium = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/14hWYkog/lithium-fabric-mc1.19.4-0.11.1.jar";
      sha512 = "f2bd271e30e5ed9f097d592db5e859208a1c6abe727dc51f83879b837c843b4f6453e99f1ca8d5225f896233ab8f7dbbb3300f10396d2a1cd2957937acfd1aa7";
    };

    # Lighting engine optimizations
    phosphor = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/hEOCdOgW/versions/mc1.19.x-0.8.1/phosphor-fabric-mc1.19.x-0.8.1.jar";
      sha512 = "13a0707b7a92726aa3154bc40978f36bb340d643c1d60e9fa2cbf8f7b0c7d3ea03c2a079f46a487df05e944eec9f5779afae9e99be7f70373e8a31d59948d487";
    };
    starlight = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.1%2B1.19/starlight-1.1.1%2Bfabric.ae22326.jar";
      sha512 = "68f81298c35eaaef9ad5999033b8caf886f3c583ae1edc25793bdd8c2cbf5dce6549aa8d969c55796bd8b0d411ea8df2cd0aaeb9f43adf0691776f97cebe1f9f";
    };

    # Memory optimizations
    ferriteCore = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/RbR7EG8T/ferritecore-5.2.0-fabric.jar";
      sha512 = "56a4ac2ed002260ee451fa9d33169ddcd01473bf46eee97061666b13fa386cd23e15238a72729e55f32d81cce8ae049c80caabf1947ba998258282226289be0c";
    };

    # Various optimizations
    modernFix = builtins.fetchurl {
      url = "https://cdn.modrinth.com/data/nmDcB62a/versions/LXlsO4Vo/modernfix-fabric-5.7.2%2Bmc1.19.4.jar";
      sha512 = "94877c4253224855753650e198df5cec908e4d07ae8f678982fa0a51a421d8f5659c2d505320a6af079da890bddca4f17d519484411bba877ca67fe545ec58b8";
    };
  };
}
