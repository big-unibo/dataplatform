FROM docker:stable

# Install bash
RUN apk add --no-cache bash

# Run the script
ADD docker_cleaner/commands.sh /usr/local/bin/shell.sh

RUN chmod 777 /usr/local/bin/shell.sh

CMD ["bash", "/usr/local/bin/shell.sh"]


