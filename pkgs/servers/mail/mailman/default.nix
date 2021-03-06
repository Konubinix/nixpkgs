{ stdenv, buildPythonPackage, fetchPypi, isPy3k, alembic, aiosmtpd, dnspython
, flufl_bounce, flufl_i18n, flufl_lock, lazr_config, lazr_delegates, passlib
, requests, zope_configuration, click, falcon, importlib-resources
, zope_component, lynx, postfix, authheaders, gunicorn
}:

buildPythonPackage rec {
  pname = "mailman";
  version = "3.3.1";
  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0idfiv48jjgc0jq4731094ddhraqq8bxnwmjk6sg5ask0jss9kxq";
  };

  propagatedBuildInputs = [
    alembic aiosmtpd click dnspython falcon flufl_bounce flufl_i18n flufl_lock
    importlib-resources lazr_config passlib requests zope_configuration
    zope_component authheaders gunicorn
  ];

  patchPhase = ''
    substituteInPlace src/mailman/config/postfix.cfg \
      --replace /usr/sbin/postmap ${postfix}/bin/postmap
    substituteInPlace src/mailman/config/schema.cfg \
      --replace /usr/bin/lynx ${lynx}/bin/lynx
  '';

  # Mailman assumes that those scripts in $out/bin are Python scripts. Wrapping
  # them in shell code breaks this assumption. Use the wrapped version (see
  # wrapped.nix) if you need the CLI (rather than the Python library).
  #
  # This gives a properly wrapped 'mailman' command plus an interpreter that
  # has all the necessary search paths to execute unwrapped 'master' and
  # 'runner' scripts.
  dontWrapPythonPrograms = true;

  meta = {
    homepage = "https://www.gnu.org/software/mailman/";
    description = "Free software for managing electronic mail discussion and newsletter lists";
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = with stdenv.lib.maintainers; [ peti ];
  };
}
