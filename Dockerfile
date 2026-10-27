FROM node:22-bookworm-slim AS frontend
WORKDIR /src/Frontend
COPY Frontend/package.json Frontend/pnpm-lock.yaml Frontend/.npmrc ./
RUN corepack enable && corepack prepare pnpm@11.25.0 --activate && pnpm install --frozen-lockfile
COPY Frontend/ ./
RUN pnpm run build

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS backend
WORKDIR /src
COPY Rental.Api/ Rental.Api/
COPY Database/ Database/
COPY --from=frontend /src/Rental.Api/wwwroot/ Rental.Api/wwwroot/
RUN dotnet publish Rental.Api/Rental.Api.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=backend /app/ ./
ENV ASPNETCORE_URLS=http://+:8080
ENV Database__SeedDemo=false
EXPOSE 8080
ENTRYPOINT ["dotnet", "Rental.Api.dll"]
