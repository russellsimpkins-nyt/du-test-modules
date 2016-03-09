%{!?_name: %define _name du-api-bitly}
%{!?_version: %define _version 1.0.0}
%{!?_build_number: %define _build_number 1}

Name:       %{_name}
Version:    %{_version}
Release:    %{_build_number}.noarch
Summary:    API to shorten and expand URLs.
Group:      DU
License:    Proprietary
URL:        http://developer.nytimes.com


%description
The Bitly API provides a service to shorten and expand URLs.  Wraps Bitlys service.

%prep

%build
cd %{_sourcedir}
make %{?_smp_mflags} 

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT
cd %{_sourcedir}
echo "{
  \"name\": \"%{_name}\",
  \"built-on\": \"$(date)\",
  \"rpm\": \"%{name}-%{version}-%{release}.%{_arch}.rpm\",
  \"full-version\": \"%{name}-%{version}-%{release}\",
  \"version\": \"%{_version}-%{_build_number}\",
  \"commit\": \"%{_commit}\",
  \"release-notes\": \"Set old pipeline back on 6.\"
}" > src/version.json
make install DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf %{_sourcedir}
rm -rf %{_buildrootdir}/%{name}-%{version}-%{release}.*

%files
%defattr(-,root,root,-)
%doc
/var

%changelog

