# Indicando imagem base

#FROM nginx:alpine

# Copia arquivos da aplicação web para pasta de publicação do Nginx
#COPY . /usr/share/nginx/html/
#COPY Web.config /etc/nginx/conf.d/Web.config
#COPY index.html /usr/share/nginx/html/index.html

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
WORKDIR /inetpub/wwwroot
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*
COPY . .
EXPOSE 80
RUN powershell -NoProfile -Command \
    Import-Module WebAdministration; \
    Set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name managedRuntimeVersion -Value 'v4.0'
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD powershell -command "try { Invoke-WebRequest -Uri http://localhost -UseBasicParsing -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"