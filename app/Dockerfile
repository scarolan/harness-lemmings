FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends zip && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# COPY all lemmings files from build context to /build/app
COPY . ./app/

# Create .jsdos bundle (zip with DOSBox config + game files for js-dos v8)
RUN cp -r app/* . && \
    mkdir -p .jsdos && \
    cp dosbox.conf .jsdos/dosbox.conf && \
    rm -rf app && \
    zip -r lemmings.jsdos .jsdos/ *

# --- Final stage ---
FROM nginx:1.27-alpine

# The context is the app/ directory, so nginx.conf and index.html are at the root
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY favicon.svg /usr/share/nginx/html/favicon.svg
COPY --from=builder /build/lemmings.jsdos /usr/share/nginx/html/lemmings.jsdos

RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    sed -i 's|/run/nginx.pid|/tmp/nginx.pid|g' /etc/nginx/nginx.conf || true && \
    touch /tmp/nginx.pid && chown nginx:nginx /tmp/nginx.pid

EXPOSE 8080

USER nginx
