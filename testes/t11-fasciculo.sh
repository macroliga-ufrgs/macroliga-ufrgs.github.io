#!/usr/bin/env bash
# Tarefa 11: o fascículo em rascunho não existe no site publicado.
source "$(dirname "$0")/lib.sh"
nao_existe publicacoes/n01/index.html "fascículo nº 1 ausente do _site"
nao_existe publicacoes/n01/capa.png "capa ausente do _site"
nao_existe publicacoes/_modelo-fasciculo "pasta-modelo ausente"
nao_tem sitemap.xml 'publicacoes/n01' "fora do sitemap"
nao_tem index.html 'Fascículo mais recente' "I2 continua em breve"
nao_tem publicacoes/index.html 'class="fasciculo fasciculo--lista"' "P2 sem fascículo publicado"
fim
