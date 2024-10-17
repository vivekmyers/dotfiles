ifeq ($(CONDA_PREFIX),)
CONDA_PREFIX = $(shell readlink -f $(HOME)/conda || echo $(HOME)/conda)
endif

CONDA_ROOT = $(shell echo "$(CONDA_PREFIX)" | sed 's|/envs/.*||')
CONDABIN = $(CONDA_ROOT)/bin
CONDA = $(CONDABIN)/mamba
PIP = $(CONDABIN)/pipx

LN = ln -sf

CONDA_CLI = vim conda-minify black pipx flake8 mypy pylint isort \
			pipdeptree pipreqs autopep8 openai jupyter tmux curl git \
			ipython jq nvitop prettier gh
CONDA_PKG = nodejs imagemagick magic-wormhole jedi moreutils
PIP_CLI = imgcat autoimport arxiv_latex_cleaner
EXTRA_CLI = wormhole node

ifeq ($(shell uname),Linux)
ifneq ($(shell hostname),phosphate)
	CONDA_PKG += universal-ctags
	EXTRA_CLI += ctags
	CONDA_CLI += expect
endif
endif

unexport PIP_NO_DEPS

BIN_CLI = $(shell ls bin) $(shell ls private/bin)
TOOLS = $(CONDA_CLI) $(PIP_CLI) $(EXTRA_CLI) $(BIN_CLI)
EXTRA = $(HOME)/.local/etc
RCEXCLUDE = cache/ ssh/ netrc
ZSH = $(HOME)/.omz
FDIR = $(ZSH)/functions
COMPDIR = $(ZSH)/completions
BIN = $(HOME)/.local/bin
SSH = $(HOME)/.ssh/config $(HOME)/.ssh/id_rsa $(HOME)/.ssh/id_rsa.pub $(HOME)/.ssh/sockets $(HOME)/.ssh/config_tpus
FUNCTIONS = $(addprefix $(FDIR)/,$(shell basename -s .zsh functions/*.zsh))
COMPLETIONS = $(addprefix $(COMPDIR)/_,$(shell basename -s .zsh completions/*.zsh))
VAR = $(HOME)/.local/var

PIPTARGETS = $(addprefix $(BIN)/,$(PIP_CLI))
CONDATARGETS = $(addprefix $(CONDABIN)/,$(CONDA_CLI))

RCFILES = $(shell find rc -mindepth 1 -type f)
RCDIRS = $(shell find rc -mindepth 1 -type d)
RCDIRTARGETS = $(addprefix $(HOME)/.,$(RCDIRS:rc/%=%))
RCEXTRA = $(SSH) $(HOME)/.netrc $(HOME)/.git-credentials $(HOME)/.config/github-copilot/hosts.json $(HOME)/.gvimrc

exclude = $(foreach target,$(1),$(if $(strip $(foreach ex,$(RCEXCLUDE),$(findstring $(ex),$(target)))),,$(target)))
getrc = $(call exclude,$(addprefix $(HOME)/.,$(shell find rc/$(1) -type f | cut -d/ -f2-)))
RCTARGETS = $(call exclude,$(addprefix $(HOME)/.,$(RCFILES:rc/%=%)))

all: conda rc shell ssh mujoco ;

rc: $(RCTARGETS) $(RCEXTRA) ;

shell: zsh omz profile $(EXTRA)/conda_hook.zsh $(VAR) ;

zsh: $(BIN)/zsh $(HOME)/.zshrc ;

$(FUNCTIONS): $(FDIR)/%: functions/%.zsh | $(FDIR)
	$(LN) $(CURDIR)/$< $@

$(COMPLETIONS): $(COMPDIR)/_%: completions/%.zsh | $(COMPDIR)
	$(LN) $(CURDIR)/$< $@

ssh: $(CONDABIN)/ssh $(SSH) secrets ;

mujoco: $(HOME)/.mujoco/mjkey.txt $(HOME)/.mujoco/mjpro150 $(HOME)/.mujoco/mujoco200 $(HOME)/.mujoco/mujoco210 ;

$(HOME)/.mujoco/mjkey.txt: rc/mujoco/mjkey.txt

.INTERMEDIATE: mjpro150.zip mujoco200.zip mujoco210.tar.gz
ifeq ($(shell uname),Linux)
mjpro150.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mjpro150_linux.zip

mujoco200.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mujoco200_linux.zip

mujoco210.tar.gz: | $(HOME)/.mujoco
	wget -O $@ https://github.com/google-deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz
else
mjpro150.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mjpro150_osx.zip

mujoco200.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mujoco200_macos.zip

mujoco210.tar.gz: | $(HOME)/.mujoco
	wget -O $@ https://github.com/google-deepmind/mujoco/releases/download/2.1.0/mujoco210-macos-x86_64.tar.gz
endif

$(HOME)/.mujoco/%: %.zip | $(HOME)/.mujoco
	rm -rf $@
	yes | unzip -d $(HOME)/.mujoco $< "$**"
	mv $@_* $@ 2>/dev/null || true

$(HOME)/.mujoco/%: %.tar.gz | $(HOME)/.mujoco
	rm -rf $@
	tar -xzf $< -C $(HOME)/.mujoco
	touch $@

secrets: $(EXTRA)/secrets.json ;

expose-%: shell
	zsh -c "source $(ZSH)/custom/utils.zsh && expose_ssh_port $*"

$(EXTRA)/conda_hook.zsh: $(CONDA) | $(EXTRA)
	truncate -s 0 $@
	echo 'unalias conda 2>/dev/null' >> $@
	echo 'eval "$$($(CONDABIN)/conda shell.zsh hook)"' >> $@
	echo 'source $(CONDA_ROOT)/etc/profile.d/mamba.sh' >> $@

ifeq ($(shell uname),Linux)
$(BIN)/zsh: $(CONDABIN)/zsh
	$(LN) $< $@
else
$(BIN)/zsh: | $(CONDA) $(BIN)
	$(LN) $(shell env -i sh -lc "which zsh") $@
endif

$(CONDABIN)/zsh: $(CONDA) | $(BIN)
	$(CONDA) install -y zsh --force-reinstall

$(HOME)/.ssh/id_rsa $(HOME)/.ssh/id_rsa.pub: $(HOME)/.ssh/%: private/ssh/% | $(HOME)/.ssh
	-cp -n $(CURDIR)/private/ssh/$(notdir $@) $@
	touch $@
	chmod 600 $@

$(HOME)/.ssh/config: private/ssh/config | $(HOME)/.ssh
	$(LN) $(CURDIR)/$< $@
	chmod 600 $@

$(HOME)/.ssh/sockets:
	mkdir -p $@

$(HOME)/.ssh/config_tpus: | $(HOME)/.ssh
	touch $@
	chmod 600 $@

$(HOME)/.netrc: private/netrc
	$(LN) $(CURDIR)/$< $@

$(HOME)/.gvimrc: private/gvimrc
	$(LN) $(CURDIR)/$< $@

$(HOME)/.git-credentials: private/git-credentials
	$(LN) $(CURDIR)/private/git-credentials $@

$(HOME)/.config/github-copilot/hosts.json: private/github-copilot/hosts.json | $(HOME)/.config/github-copilot
	$(LN) $(CURDIR)/private/github-copilot/hosts.json $@

conda: $(CONDA) $(HOME)/conda $(TOOLS) ;

vim: $(HOME)/.vimrc $(HOME)/.vim/plug.log $(HOME)/.vim/tags

$(HOME)/.vim/plug.log: $(HOME)/.vim/autoload/load.vim $(BIN)/vim $(HOME)/.vim/autoload/plug.vim
	rm -f $@
	yes | $(BIN)/vim -E +'PlugInstall --sync' +"w $@" +qall 1>/dev/null
	cat $@

$(HOME)/.vim/tags: $(BIN)/ctags $(HOME)/.vim/plug.log | $(HOME)/.vim
	$(BIN)/ctags --exclude='*.json' --exclude='*.html' --quiet -R -f $@ $(HOME)/.vim

$(HOME)/.vim/autoload/plug.vim: | $(BIN)/curl $(HOME)/.vim
	$(BIN)/curl -fLo $@ --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

$(TOOLS): %: $(BIN)/% ;

$(PIPTARGETS): $(BIN)/%: | $(BIN) $(PIP)
	$(PIP) install $*

$(BIN)/wormhole:
	$(PIP) install magic-wormhole

$(CONDABIN)/node:
	-$(CONDA) uninstall -y nodejs
	$(CONDA) install -y nodejs

$(CONDABIN)/ssh:
	$(CONDA) install -y openssh

$(CONDABIN)/ctags:
	$(CONDA) list | grep ctags && $(CONDA) uninstall -y universal-ctags || true
	$(CONDA) install -y universal-ctags || $(LN) $(shell which ctags) $@

.INTERMEDIATE: miniforge.sh
miniforge.sh:
	wget -O miniforge.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(shell uname)-$(shell uname -m).sh"

$(CONDA): miniforge.sh
	bash miniforge.sh -b -p $(CONDA_ROOT)

$(CONDA_ROOT): $(CONDA)
	test -d $@
	test -x $<

ifneq ($(HOME)/conda,$(CONDA_ROOT))
$(HOME)/conda: $(CONDA_ROOT) $(CONDA)
	$(LN) $< $@
endif

define dirdep
$(1): | $(dir $(patsubst %/,%,$(1)))
endef

$(foreach dep,$(RCTARGETS) $(RCDIRTARGETS),$(eval $(call dirdep,$(dep))))

.SECONDEXPANSION:
$(shell ls rc): $$(call getrc,$$@)

$(RCTARGETS): $(HOME)/.%: rc/%
	$(LN) $(CURDIR)/$< $@

$(RCDIRTARGETS):
	mkdir -p $@

%/:
	mkdir -p $@

$(CONDATARGETS): $(CONDA)

.SECONDARY: $(EXTRA)/environment.yml $(addprefix $(CONDABIN)/,$(EXTRA_CLI)) $(addprefix $(BIN)/,$(EXTRA_CLI))

$(CONDABIN)/%: $(EXTRA)/environment.yml
	$(shell test -x $@ || echo $(CONDA) install -y $(notdir $@))
	touch $@

$(CONDABIN)/wormhole: $(CONDA)
	$(CONDA) install -y magic-wormhole

$(CONDABIN)/convert: $(CONDA)
	$(CONDA) install -y imagemagick

$(BIN)/%: $(CURDIR)/bin/% | $(BIN)
	$(LN) $< $@
	chmod +x $@

$(BIN)/%: $(CURDIR)/private/bin/% | $(BIN)
	$(LN) $< $@
	chmod +x $@

$(BIN)/%: $(CONDABIN)/% | $(BIN)
	$(LN) $< $@

$(EXTRA)/environment.yml: $(CONDA) | $(EXTRA)
	$(CONDA) install -y $(CONDA_CLI) $(CONDA_PKG)
	$(CONDABIN)/conda-minify -n base > $@

$(EXTRA)/secrets.json: private/secrets.json | $(EXTRA)
	cp $< $@

DIRS = $(EXTRA) $(BIN) $(FDIR) $(VAR) $(COMPDIR)
$(DIRS):
	mkdir -p $@

print-%:
	@echo $* = $($*)

getrc-%:
	@echo $(call getrc,$*)

profile: omz init $(patsubst profile/%.zsh,$(ZSH)/custom/%.zsh,$(wildcard profile/*.zsh)) \
	$(patsubst private/profile/%.zsh,$(ZSH)/custom/%.zsh,$(wildcard private/profile/*.zsh)) $(FUNCTIONS) $(COMPLETIONS) ;

init: $(ZSH)/custom/init.zsh ;

omz: $(ZSH) $(addprefix $(ZSH)/custom/plugins/,conda-zsh-completion zsh-autosuggestions zsh_codex zsh-syntax-highlighting) ;

$(ZSH): $(CONDABIN)/ssh
	rm -rf $@
	git clone https://github.com/vivekmyers/ohmyzsh.git $@

$(ZSH)/custom/%: $(ZSH) | $(ZSH)/custom/plugins

$(ZSH)/custom/plugins/conda-zsh-completion:
	rm -rf $@
	git clone https://github.com/conda-incubator/conda-zsh-completion $@

$(ZSH)/custom/plugins/zsh-autosuggestions:
	rm -rf $@
	git clone https://github.com/zsh-users/zsh-autosuggestions $@

$(ZSH)/custom/plugins/zsh_codex:
	rm -rf $@
	git clone https://github.com/tom-doerr/zsh_codex.git $@

$(ZSH)/custom/plugins/zsh-syntax-highlighting:
	rm -rf $@
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $@

$(ZSH)/custom/plugins:
	mkdir -p $@

$(ZSH)/custom/%.zsh: profile/%.zsh | $(ZSH)/custom
	$(LN) $(CURDIR)/$< $@

$(ZSH)/custom/%.zsh: private/profile/%.zsh | $(ZSH)/custom
	$(LN) $(CURDIR)/$< $@

$(ZSH)/custom/init.zsh: | $(ZSH)/custom
	echo 'export CONFIGDIR=$(CURDIR)' > $@

none:
	@echo "No config specified to build"

clean:
	rm -rf $(CONDA_PREFIX) $(HOME)/conda $(ZSH) $(EXTRA) $(BIN) $(FDIR) miniforge.sh $(HOME)/.vim* $(HOME)/.zshrc $(HOME)/.mujoco $(HOME)/.local

