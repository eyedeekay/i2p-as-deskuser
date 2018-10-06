
USE_AVX=no
USE_AESNI=no
USE_STATIC=yes
USE_UPNP=yes


HOME=$(shell pwd)

VERSION=$(shell curl -s "https://api.github.com/repos/PurpleI2P/i2pd/releases/latest"|grep "tag_name"|sed -E 's|.*"([^"]+)".*|\1|')

i2pd.$(VERSION).tar.gz:
	rm -vf i2pd-*.tar.gz
	curl -L https://github.com/PurpleI2P/i2pd/archive/$(VERSION).tar.gz -o i2pd.$(VERSION).tar.gz
	rm -rf i2pd-$(VERSION)
	tar xvzf i2pd.$(VERSION).tar.gz

get: i2pd.$(VERSION).tar.gz

i2pd-$(VERSION)/i2pd:
	cd i2pd-$(VERSION)
	cd i2pd-$(VERSION) && make

release: i2pd-$(VERSION)/i2pd

current: get release

config: $(HOME)/.config/i2pd $(HOME)/.config/i2pd/i2pd.conf $(HOME)/.config/i2pd/tunnels.conf

clean:
	rm -rf $(HOME)/.config/i2pd/* i2pd-$(VERSION)

$(HOME)/.config/i2pd:
	mkdir -p $(HOME)/.config/i2pd $(HOME)/.local/i2pd

$(HOME)/.config/i2pd/i2pd.conf:
	@echo "" | tee $(HOME)/.config/i2pd/i2pd.conf
	@echo "ipv4 = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "ipv6 = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "nat = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "bandwidth = X" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "ntcp2.enabled = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[upnp]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "enabled = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[reseed]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "verify = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[http]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "address = 127.0.0.1" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "port = 7070" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[httpproxy]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "enabled = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "address = 127.0.0.1" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "port = 4444" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[socksproxy]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "enabled = false" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "#address = 127.0.0.1" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "#port = 7656" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[sam]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "enabled = true" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "address = 127.0.0.1" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "port = 7656" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[bob]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "enabled = false" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "[i2cp]" | tee -a $(HOME)/.config/i2pd/i2pd.conf
	@echo "enabled = false" | tee -a $(HOME)/.config/i2pd/i2pd.conf

$(HOME)/.config/i2pd/tunnels.conf:
	@echo "" | tee $(HOME)/.config/i2pd/tunnels.conf
	@echo "[IRC-IRC2P]" | tee -a $(HOME)/.config/i2pd/tunnels.conf
	@echo "type = client" | tee -a $(HOME)/.config/i2pd/tunnels.conf
	@echo "address = 127.0.0.1" | tee -a $(HOME)/.config/i2pd/tunnels.conf
	@echo "port = 6668" | tee -a $(HOME)/.config/i2pd/tunnels.conf
	@echo "destination = irc.postman.i2p" | tee -a $(HOME)/.config/i2pd/tunnels.conf
	@echo "destinationport = 6667" | tee -a $(HOME)/.config/i2pd/tunnels.conf
	@echo "keys = irc-keys.dat" | tee -a $(HOME)/.config/i2pd/tunnels.conf

run: config
	i2pd-$(VERSION)/i2pd $(HOME)/.local/i2pd/i2pd
	cd $(HOME)/.local/i2pd/ && ./i2pd \
		--conf=$(HOME)/.config/i2pd/i2pd.conf \
		--tunconf=$(HOME)/.config/i2pd/tunnels.conf \
		--datadir=$(HOME)/.local/i2pd \
		--log=stdout

all: clean current config run
