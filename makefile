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
			ipython jedi 
CONDA_PKG = nodejs imagemagick magic-wormhole
PIP_CLI = imgcat autoimport
EXTRA_CLI = wormhole
BIN_CLI = $(shell ls bin)
TOOLS = $(CONDA_CLI) $(PIP_CLI) $(EXTRA_CLI) $(BIN_CLI)
EXTRA = $(HOME)/.local/etc
RCEXCLUDE = cache/ .git/ ssh/id_rsa
ZSH = $(HOME)/.omz
FDIR = $(ZSH)/functions
BIN = $(HOME)/.local/bin
FUNCTIONS = $(addprefix $(FDIR)/,$(shell basename -s .zsh functions/*.zsh))

PIPTARGETS = $(addprefix $(BIN)/,$(PIP_CLI))
CONDATARGETS = $(addprefix $(CONDABIN)/,$(CONDA_CLI))

RCFILES = $(shell find rc -mindepth 1 -type f)
RCDIRS = $(shell find rc -mindepth 1 -type d)
RCDIRTARGETS = $(addprefix $(HOME)/.,$(RCDIRS:rc/%=%))
RCEXTRA = $(HOME)/.ssh/id_rsa $(HOME)/.ssh/id_rsa.pub

exclude = $(foreach target,$(1),$(if $(strip $(foreach ex,$(RCEXCLUDE),$(findstring $(ex),$(target)))),,$(target)))
getrc = $(call exclude,$(addprefix $(HOME)/.,$(shell find rc/$(1) -type f | cut -d/ -f2-)))
RCTARGETS = $(call exclude,$(addprefix $(HOME)/.,$(RCFILES:rc/%=%)))

all: conda rc shell ssh mujoco ;
	
rc: $(RCTARGETS) $(RCEXTRA) ;

shell: zsh omz profile $(EXTRA)/conda_hook.zsh ;

zsh: $(BIN)/zsh $(HOME)/.zshrc ;

$(FUNCTIONS): $(FDIR)/%: functions/%.zsh | $(FDIR)
	$(LN) $(CURDIR)/$< $@

ssh: $(call getrc,ssh) secrets ;

mujoco: $(HOME)/.mujoco/mjkey.txt $(HOME)/.mujoco/mjpro150 $(HOME)/.mujoco/mujoco200 ;

$(HOME)/.mujoco/mjkey.txt: rc/mujoco/mjkey.txt

.INTERMEDIATE: mjpro150.zip mujoco200.zip
ifeq ($(shell uname),Linux)
mjpro150.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mjpro150_linux.zip

mujoco200.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mujoco200_linux.zip
else
mjpro150.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mjpro150_osx.zip

mujoco200.zip: | $(HOME)/.mujoco
	wget -O $@ https://www.roboti.us/download/mujoco200_macos.zip
endif

$(HOME)/.mujoco/%: %.zip | $(HOME)/.mujoco
	rm -rf $@
	unzip -d $(HOME)/.mujoco $< "$**"
	mv $@_* $@ 2>/dev/null || true

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
	
$(HOME)/.ssh/id_rsa $(HOME)/.ssh/id_rsa.pub:
	cp -n rc/ssh/$(notdir $@) $@ || touch $@

conda: $(CONDA) $(HOME)/conda $(TOOLS) ;

vim: $(HOME)/.vimrc $(HOME)/.vim/plug

$(HOME)/.vim/plug: $(HOME)/.vimrc $(BIN)/vim $(HOME)/.vim/autoload/plug.vim
	rm -f $@
	$(BIN)/vim +'PlugInstall --sync' +"w $@" +qall 1>/dev/null
	cat $@

$(HOME)/.vim/autoload/plug.vim: $(BIN)/curl | $(HOME)/.vim
	$(BIN)/curl -fLo $@ --create-dirs \
					https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

$(TOOLS): %: $(BIN)/% ;

$(PIPTARGETS): $(BIN)/%: $(PIP) | $(BIN)
	PIP_NO_DEPS= $(PIP) install --force $*

$(BIN)/wormhole:
	PIP_NO_DEPS= $(PIP) install --force magic-wormhole

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

$(foreach dep,$(RCTARGETS) $(RCDIRTARGETS) $(RCEXTRA),$(eval $(call dirdep,$(dep))))

.SECONDEXPANSION:
$(shell ls rc): $$(call getrc,$$@)

$(RCTARGETS): $(HOME)/.%: rc/%
	$(LN) $(CURDIR)/$< $@

$(RCDIRTARGETS):
	mkdir -p $@

%/:
	mkdir -p $@

$(CONDATARGETS): $(CONDA)

$(CONDABIN)/%: $(EXTRA)/environment.yml
	test -x $@ || { rm -f $< && $(MAKE) $<;}
	touch $@

$(CONDABIN)/wormhole: $(CONDA)
	$(CONDA) install -y magic-wormhole

$(CONDABIN)/convert: $(CONDA)
	$(CONDA) install -y imagemagick

$(BIN)/%: $(CURDIR)/bin/% | $(BIN)
	$(LN) $< $@
	chmod +x $@

$(BIN)/%: $(CONDABIN)/% | $(BIN)
	$(LN) $< $@

$(EXTRA)/environment.yml: $(CONDA) | $(EXTRA)
	$(CONDA) install -y $(CONDA_CLI) $(CONDA_PKG)
	$(CONDABIN)/conda-minify -n base > $@

$(EXTRA)/secrets.json: secrets.json | $(EXTRA)
	cp $< $@

DIRS = $(EXTRA) $(BIN) $(FDIR) 
$(DIRS):
	mkdir -p $@

print-%:
	@echo $* = $($*)

getrc-%:
	@echo $(call getrc,$*)

profile: omz init $(patsubst profile/%.zsh,$(ZSH)/custom/%.zsh,$(wildcard profile/*.zsh)) $(FUNCTIONS) ;

init: $(ZSH)/custom/init.zsh ;

$(ZSH)/custom/%.zsh: profile/%.zsh | $(ZSH)/custom
	$(LN) $(CURDIR)/$< $@

$(ZSH)/custom/init.zsh: | $(ZSH)/custom
	echo 'export CONFIGDIR=$(CURDIR)' > $@

none:
	@echo "No config specified to build"

clean:
	rm -rf $(CONDA_PREFIX) $(HOME)/conda $(ZSH) $(EXTRA) $(BIN) $(FDIR) miniforge.sh $(HOME)/.vim* $(HOME)/.zshrc $(HOME)/.mujoco $(HOME)/.local
