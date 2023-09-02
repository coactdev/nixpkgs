{ lib
, cacert
, curl
, makeRustPlatform
, fromManifestFile
, from-manifest
, makeWrapper
, pkg-config
, openssl
, stdenv
, zig
}: let
    toolchain = (fromManifestFile rust-manifest).minimalToolchain;
in
  (makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  })
  .buildRustPackage rec {
    pusername = "coactdev";
    pname = "cargo-lambda";
    version = "3e4de72a29d48f56f3cacc9d036946a2b1292269";

    src = builtins.fetchGit {
      url = "https://github.com/coactdev/cargo-lambda.git";
      rev = "${version}";
      ref = "dev";
    };

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-/ny7R8Ap4m2DLoyH0Qh49rz3tB3RRYmw7tWo0sIUn5I=";
      };
    };
    #https://artemis.sh/2023/07/08/nix-rust-project-with-git-dependencies.html

    nativeCheckInputs = [cacert];

    nativeBuildInputs = [ makeWrapper pkg-config ];

    #buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ curl CoreServices Security ];
    buildInputs = [ openssl ];

    checkFlags = [
      # Disabled because they accesses the network.
      "--skip=test_build_basic_extension"
      "--skip=test_build_basic_function"
      "--skip=test_build_http_function"
      "--skip=test_build_logs_extension"
      "--skip=test_build_telemetry_extension"
      "--skip=test_download_example"
      "--skip=test_init_subcommand"
      "--skip=test_init_subcommand_without_override"
      "--skip=test_build_basic_zip_extension"
      "--skip=test_build_basic_zip_function"
      "--skip=test_build_internal_zip_extension"
    ];

    # remove date from version output to make reproducible
    postPatch = ''
      rm crates/cargo-lambda-cli/build.rs
    '';

    postInstall = ''
      wrapProgram $out/bin/cargo-lambda --prefix PATH : ${lib.makeBinPath [ zig ]}
    '';

    CARGO_LAMBDA_BUILD_INFO = "(nixpkgs.patch)";
    
    meta = with lib; {
      description = "A Cargo subcommand to help you work with AWS Lambda";
      homepage = "https://cargo-lambda.info";
      license = licenses.mit;
      maintainers = with maintainers; [ taylor1791 calavera ];
    };
  }
