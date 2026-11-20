{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  hwloc,
  llvmPackages,
  libxml2, # required for statically linked llvm
  spirv-llvm-translator,
  spirv-tools,
  lttng-ust,
  opencl-headers,
  ocl-icd,
  python3,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pocl";
  version = "7.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "pocl";
    repo = "pocl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aAqg8AgiAny6FgYa+90Czeff3b6CPYBBIQshR7J2p64=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace pocld/shared_cl_context.cc --replace-fail \
      "Dev.getInfo<CL_DEVICE_GLOBAL_MEM_SIZE>()" \
      "static_cast<size_t>(Dev.getInfo<CL_DEVICE_GLOBAL_MEM_SIZE>())"
  '';

  cmakeFlags =
    (lib.mapAttrsToList lib.cmakeBool {
      # avoid the runtime linker pulling in a different llvm e.g. from graphics drivers
      "STATIC_LLVM" = true;
      "ENABLE_POCL_BUILDING" = false;
      "POCL_ICD_ABSOLUTE_PATH" = true;
      "ENABLE_ICD" = true;
      "ENABLE_REMOTE_CLIENT" = true;
      "ENABLE_REMOTE_SERVER" = true;
    })
    ++ (lib.mapAttrsToList lib.cmakeFeature {
      # Since 7.2, pocl's cmake prefers find_package(LLVM CONFIG) and then
      # assumes Clang's cmake config lives as a sibling dir under the same
      # prefix as LLVM's, which doesn't hold with nixpkgs' split llvm/clang
      # outputs. Forcing WITH_LLVM_CONFIG keeps it on the llvm-config path.
      "WITH_LLVM_CONFIG" = "${lib.getDev llvmPackages.llvm}/bin/llvm-config";
      # On that path it then searches for host clang/LLVM tool binaries next
      # to llvm-config, which also doesn't hold here (nixpkgs' llvm-config
      # lives in a separate "dev" output from opt/llc/etc, and clang is a
      # wholly separate package). Pre-set every HOST_* cache var so
      # find_program()/find_llvm_program_or_die() short-circuit instead of
      # searching. The old CLANG/CLANGXX cache vars this replaces aren't
      # read by pocl's cmake at all anymore.
      "HOST_CLANG" = "${llvmPackages.clangUseLLVM}/bin/clang";
      "HOST_CLANGXX" = "${llvmPackages.clangUseLLVM}/bin/clang++";
      "HOST_LLVM_OPT" = "${lib.getBin llvmPackages.llvm}/bin/opt";
      "HOST_LLVM_LLC" = "${lib.getBin llvmPackages.llvm}/bin/llc";
      "HOST_LLVM_AS" = "${lib.getBin llvmPackages.llvm}/bin/llvm-as";
      "HOST_LLVM_DIS" = "${lib.getBin llvmPackages.llvm}/bin/llvm-dis";
      "HOST_LLVM_LINK" = "${lib.getBin llvmPackages.llvm}/bin/llvm-link";
      "HOST_LLVM_SPIRV" = "${spirv-llvm-translator}/bin/llvm-spirv";
      "HOST_SPIRV_LINK" = "${spirv-tools}/bin/spirv-link";
      "HOST_LLVM_FILECHECK" = "${lib.getBin llvmPackages.llvm}/bin/FileCheck";
    })
    # Only x86_64 supports "distro" which allows runtime detection of SSE/AVX
    ++ lib.optionals stdenv.hostPlatform.isx86_64 [
      (lib.cmakeFeature "KERNELLIB_HOST_CPU_VARIANTS" "distro")
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isx86_64) [
      (lib.cmakeFeature "LLC_HOST_CPU" "generic")
    ]
    ++ (
      # Fixes error: ld: cannot find -lgcc / -lgcc_s when linking from libpocl on
      # host
      # Should match the flags from : "${targetPackages.stdenv.cc}/nix-support/cc-ldflags
      # But, we cannot use the file here without doing import from derivation
      let
        inherit (stdenv) targetPlatform hostPlatform;

        gccForLibs = stdenv.cc.cc;
        gccForLibs_solib =
          lib.getLib gccForLibs
          + lib.optionalString (targetPlatform != hostPlatform) "/${targetPlatform.config}";
      in
      [
        (lib.cmakeFeature "EXTRA_HOST_LD_FLAGS" "-L${gccForLibs}/lib/gcc/${targetPlatform.config}/${gccForLibs.version} -L${gccForLibs_solib}/lib")
      ]
    );

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    hwloc
    libxml2
    llvmPackages.llvm
    llvmPackages.libclang
    opencl-headers
    ocl-icd
    spirv-tools
    spirv-llvm-translator
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    lttng-ust
  ];

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    export HWLOC_SYNTHETIC="node:1 core:1 pu:1"
    export OCL_ICD_VENDORS=$out/etc/OpenCL/vendors
    $out/bin/poclcc -o poclcc.cl.pocl $src/examples/poclcc/poclcc.cl 2>poclcc.err
    if grep error poclcc.err ; then
      cat poclcc.err
      false
    fi

    runHook postInstallCheck
  '';

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Portable open source (MIT-licensed) implementation of the OpenCL standard";
    homepage = "https://portablecl.org";
    changelog = "https://github.com/pocl/pocl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      jansol
      johnrtitor
      xddxdd
    ];
    platforms = lib.platforms.unix;
  };
})
