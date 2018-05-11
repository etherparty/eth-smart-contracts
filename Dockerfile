FROM luongnguyen/oyente


# ADD ./contracts   /oyente/contracts

WORKDIR /oyente/

EXPOSE 9000

CMD ["/bin/bash"]