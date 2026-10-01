# Criterivox Deployment

## Hosted application

Criterivox has a hosted web deployment on Railway.

- **Web application:** https://criterivox-web-production.up.railway.app
- **API health endpoint:** https://criterivox-api-production.up.railway.app/health

The web URL is the browser-facing application. The API health URL is a service health endpoint, not the user interface.

## Hosting and domains

Railway provides the current `up.railway.app` hostnames. These are valid public deployment URLs and are not mandatory naming conventions. A custom domain can be connected through Railway's domain settings by configuring the DNS records Railway provides. The app can continue to be hosted on Railway while users access it through a custom domain.

## Deployment configuration

The repository's deployment configuration and service settings remain the source of truth for build commands, start commands, environment variables, and service relationships. Keep secrets in the hosting platform's secret/environment-variable settings, not in source control or this document.

## Status and limitations

A reachable deployment URL indicates that a hosted endpoint is available, but it does not by itself establish that every application workflow is functioning, that the latest commit is deployed, or that the prototype is production-ready. Validate the web interface, API health, and critical user flows after deployments. Criterivox remains an evolving research prototype; deployment is separate from empirical research validation.
