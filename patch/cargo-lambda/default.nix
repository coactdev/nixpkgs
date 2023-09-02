{ lib
, cacert
, curl
, rustPlatform
, fetchFromGitHub
, makeWrapper
, pkg-config
, openssl
, stdenv
, zig
}:


rustPlatform.buildRustPackage rec {
  pusername = "coactdev";
  pname = "cargo-lambda";
  version = "6b11f264f324581a0112dd8cdbd0e125a55369ef";

  src = fetchgit {
    owner = pusername;
    repo = pname;
    url = "https://github.com/coactdev/cargo-lambda.git";
    rev = "${version}";
    ref = "dev";
    sha256 = "sha256-A6pZG4DNqnxaJlBCRURUjNINhAuppdZ0esTDc1oclWw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cargo-test-macro-0.1.0" = "sha256-XvTKAbP/r1BthpEM84CYZ2yfJczxqzscGkN4JXLgvfA=";
    };
  };


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
