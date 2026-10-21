#!/usr/bin/env bash
# Endereços curtos do nº 1: ficam em rascunho até o lançamento, junto com o fascículo.
source "$(dirname "$0")/lib.sh"
nao_existe n01/index.html "atalho /n01 só no lançamento"
nao_existe n01/opine/index.html "atalho /n01/opine só no lançamento"
nao_existe n01/opine/pdf/index.html "atalho /n01/opine/pdf só no lançamento"
fim
