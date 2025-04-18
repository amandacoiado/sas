/* Programa de configuração inicial - Bancoramos */
/* Aluno: execute este código completo uma vez para configurar seu ambiente */

/* 1. Criar diretório bancoramos no SAS OnDemand */
%LET aluno_id = %SYSGET(USER); /* Obtém o ID do aluno */
%LET caminho_base = /home/&aluno_id/bancoramos; /* Caminho absoluto */

/* Verifica e cria o diretório se não existir */
data _null_;
  rc = filename("dircheck", "&caminho_base");
  if exist("dircheck") then
    put "NOTA: Diretório bancoramos já existe.";
  else do;
    rc = dcreate("bancoramos", "/home/&aluno_id");
    put "SUCESSO: Diretório bancoramos criado em &caminho_base";
  end;
run;

/* 2. Baixar todos os arquivos do GitHub */
%MACRO baixar_arquivos;
  /* Lista de todos os datasets do repositório */
  %LET arquivos = agencias bancos cidades clientes contas estados 
                 locais tiposconta tipostransacao transacoes;
  
  %DO i=1 %TO %SYSFUNC(COUNTW(&arquivos));
    %LET dataset = %SCAN(&arquivos, &i);
    
    /* URL do arquivo no GitHub (formato raw) */
    FILENAME github URL 
      "https://github.com/amandacoiado/sas/raw/main/bancoramos/&dataset..sas7bdat";
    
    /* Cópia para o diretório local */
    FILENAME local "&caminho_base/&dataset..sas7bdat";
    
    data _null_;
      rc = fcopy('github', 'local');
      if rc = 0 then
        put "SUCESSO: Arquivo &dataset..sas7bdat baixado com êxito.";
      else
        put "ERRO: Falha ao baixar &dataset..sas7bdat. Código: " rc=;
    run;
  %END;
%MEND;

%baixar_arquivos;

/* 3. Criar a biblioteca RAMOS */
LIBNAME RAMOS "&caminho_base";

/* 4. Verificar se tudo foi configurado corretamente */
PROC DATASETS LIBRARY=RAMOS;
  CONTENTS DATA=_ALL_ NODS;
RUN;

/* 5. Mensagem final */
%PUT;
%PUT NOTA: Configuração completa!;
%PUT Biblioteca RAMOS criada com sucesso em: &caminho_base;
%PUT Todos os datasets foram baixados do GitHub e estão disponíveis.;
%PUT;