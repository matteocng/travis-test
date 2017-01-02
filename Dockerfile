FROM tatsushid/tinycore-node:7.3
LABEL maintainer "matteocng <matteocng+dockerhub@outlook.com>"

# We need to run 'tce-load' as 'tc'.
USER tc

# Install elfutils because Flowtype needs it.
RUN tce-load -wic bash gnupg tar buildutils elfutils && \
    rm -rf /tmp/tce/optional/*

# The rest of this file is run as 'root'.
USER root

# We do not symlink yarn because it would not detect the basename correctly.
RUN curl -o- -L https://yarnpkg.com/install.sh | bash && \
    npm uninstall -g --no-progress --loglevel=silent npm > /dev/null 2>&1 && \
    echo $'#!/bin/sh\nexec yarn "$@"' > /usr/local/bin/npm && \
    chmod +x /usr/local/bin/npm

ENV PATH /root/.yarn/bin:$PATH

VOLUME /app

WORKDIR /app

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]

CMD ["yarn"]
