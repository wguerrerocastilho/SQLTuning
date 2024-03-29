USE [BenchNFe]
GO
/****** Object:  StoredProcedure [dbo].[CriaTabelas02]    Script Date: 10/01/2024 15:30:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ==========================================================================================
     Author     : Waldemar Guerrero
     Create date: 06/11/2019
     Description: 
                  Cria tabelas para teste de benchmark

                  Tabelas sem terminação numérica representam
				  Chave primária simples IdNFe (INT) e clusterada
				  com indice único não clusterado com CPFJ + FILIAL + IdNFe 
                  JOIN declarando apenas a primary key
				  
				  Tabelas terminadas em 01 representam o modo Kalunga
                  Chave primária composta clusterada (CPFJ + FILIAL + IdNFe )
				  JOIN declarando toda a chave
                  
				  Tabelas terminadas em 02:
                  Chave primária simples IdNFe (INT)
				  com indice único clusterado com CPFJ + FILIAL + IdNFe 
                  JOIN declarando apenas a primary key
                  
				  EXEC CriaTabelas02

   ==========================================================================================*/

ALTER PROCEDURE [dbo].[CriaTabelas02] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('Benchmark') IS NULL
    BEGIN
	    CREATE TABLE Benchmark (
		    IdBench      SMALLINT IDENTITY (1, 1),
			tDsOperacao  VARCHAR(MAX)  NULL  ,
			dDtInicio    SMALLDATETIME NULL  ,
			dDtFim       SMALLDATETIME NULL CONSTRAINT DefDtFim DEFAULT GETDATE()
		)
    END
    
    IF OBJECT_ID('NFe.Prod') IS NULL
    BEGIN
        CREATE TABLE NFe.Prod(
             cProd             VARCHAR(060)       NOT NULL PRIMARY KEY,  -- Código do produto ou serviço
             cEAN              VARCHAR(014)       NOT NULL            ,  -- GTIN (Global Trade Item Number) do produto, antigo código EAN ou código de barras.
             xProd             VARCHAR(120)       NOT NULL            ,  -- Descrição do produto ou serviço
             NCM               VARCHAR(008)       NOT NULL            ,  -- Código NCM com 8 dígitos ou 2 dígitos (gênero)
             EXTIPI            VARCHAR(003)       NULL                ,  -- EX_TIPI
             CFOP              DECIMAL(004)       NOT NULL            ,  -- Código Fiscal de Operações e Prestações
             uCOM              VARCHAR(006)       NOT NULL            ,  -- Unidade Comercial
             qCOM              DECIMAL(11,4)      NOT NULL            ,  -- Quantidade Comercial
             vUnCom            DECIMAL(21,10)     NOT NULL            ,  -- Valor Unitário de comercialização
             vProd             DECIMAL(15,2)      NOT NULL            ,  -- Valor Total Bruto dos Produtos ou Serviços
             cEANTrib          VARCHAR(014)       NOT NULL            ,  -- GTIN (Global Trade Item Number) da unidade tributável, antigo código EAN ou código de barras.
             uTrib             VARCHAR(006)       NOT NULL            ,  -- Unidade Tributável
             qTrib             DECIMAL(11,4)      NOT NULL            ,  -- Quantidade Tributável
             vUnTrib           DECIMAL(21,10)     NULL                ,  -- Valor Unitário de tributação
             vFrete            DECIMAL(15,2)      NULL                ,  -- Valor Total do Frete
             vSeg              DECIMAL(15,2)      NULL                ,  -- Valor Total do Seguro
             vDesc             DECIMAL(15,2)      NULL                ,  -- Valor do Desconto
             vOutro_item       DECIMAL(15,2)      NULL                ,  -- Outras despesas acessórias
             indTot            TINYINT            NOT NULL            ,  -- Indica se valor do Item (vProd) entra no valor total da NF-e (vProd)
             nTipoItem         TINYINT            NOT NULL            ,  -- Número do tipo do Item
             dProd             TINYINT            NULL                ,  -- Destaque de Produtos Perigosos
             xPed_item         VARCHAR(015)       NULL                ,  -- Número do Pedido de Compra
             nItemPed          VARCHAR(006)       NULL                ,  -- Item do Pedido de Compra
             nFCI              CHAR(036)          NULL                ,  -- Ficha de Conteúdo de Importação
             nRECOPI           VARCHAR(020)       NULL                ,  -- Número do RECOPI
             CEST              VARCHAR(007)       NULL                ,  -- Código CEST
             indEscala         VARCHAR(001)       NULL                ,  -- Indicador de escala relevante
             CNPJFab           VARCHAR(014)       NULL                ,  -- CNPJ do Fabricante da Mercadoria
             cBenef            VARCHAR(020)       NULL                   -- Código de Benefício Fiscal na UF aplicado ao item
        )
    END
    
    IF OBJECT_ID('NFe.NFe02') IS NULL
    BEGIN
        CREATE TABLE NFe.NFe02( 
                 CPFJ                VARCHAR(09)        NOT NULL ,  --
    			 FILIAL              VARCHAR(04)        NOT NULL ,  -- 
                 nIdNFe              INT                NOT NULL IDENTITY(1,1) PRIMARY KEY NONCLUSTERED, --  CONSTRAINT PK_NFE PRIMARY KEY NONCLUSTERED               ,  -- Chave primaria da tabela
    			 cNF                 DECIMAL(8)         NULL                  ,  -- Código Numérico que compõe a Chave de Acesso
                 cUF                 SMALLINT           NOT NULL              ,  -- Código da UF do emitente do Documento Fiscal
                 natOp               VARCHAR(060)       NOT NULL              ,  -- Descrição da Natureza da Operação
                 mod                 CHAR(002)          NULL                  ,  -- Código do Modelo do Documento Fiscal
                 serie               VARCHAR(003)       NOT NULL              ,  -- Série do Documento Fiscal
                 nNF                 INT                NOT NULL              ,  -- Número do Documento Fiscal 
                 dhEmi               SMALLDATETIME      NOT NULL              ,  -- Data de emissão do Documento Fiscal
                 fusoHorario         CHAR(006)          NOT NULL              ,  -- Fuso horário da emissão
                 dhSaiEnt            SMALLDATETIME      NULL                  ,  -- Data de Saída ou da Entrada da Mercadoria/Produto
                 tpNf                TINYINT            NOT NULL              ,  -- Tipo de Operação
                 idDest              TINYINT            NOT NULL              ,  -- Identificador de local de destino da operação
                 indFinal            TINYINT            NOT NULL              ,  -- Indica operação com Consumidor final
                 indPres             TINYINT            NOT NULL              ,  -- Indicador de presença do comprador no estabelecimento comercial no momento da operação
                 cMunFg              INT                NOT NULL              ,  -- Código do Município de Ocorrência do Fato Gerador
                 tpImp               TINYINT            NOT NULL              ,  -- Formato de Impressão do DANFE
                 tpEmis              TINYINT            NOT NULL              ,  -- Forma de Emissão da NF-e
                 tpAmb               TINYINT            NOT NULL              ,  -- Ambiente de emissão
                 xJust               VARCHAR(256)       NULL                  ,  -- Justificativa de entrada em contingência
                 dhCont              SMALLDATETIME      NULL                  ,  -- Data e Hora da entrada em Contingência
                 finNFe              TINYINT            NOT NULL              ,  -- Finalidade de emissão da NF-e
                 EmailArquivos       VARCHAR(1000)      NULL                  ,  -- E-mails para recebimento dos arquivos
                 NumeroPedido        VARCHAR(100)       NULL                  ,  -- Número do pedido
                 refNFe              CHAR(44)           NULL                  ,  -- Chave de acesso da NF-e referenciada
                 cUF_refNFE          TINYINT            NULL                  ,  -- Código da UF do emitente do Documento Fiscal
                 AAMM                DECIMAL(4)         NULL                  ,  -- Ano e Mês de emissão da NF
                 CNPJ                VARCHAR(014)       NULL                  ,  -- CNPJ do emitente
                 CPF                 VARCHAR(011)       NULL                  ,  -- CPF do Produtor Rural
                 mod_refNFE          TINYINT            NULL                  ,  -- Modelo do Documento Fiscal
                 serie_refNFE        VARCHAR(003)       NULL                  ,  -- Série do Documento Fiscal
                 nNF_refNFE          INT                NULL                  ,  -- Número do Documento Fiscal
                 IE_refNFP           VARCHAR(014)       NULL                  ,  -- IE do emitente
                 RefCte              CHAR(44)           NULL                  ,  -- Chave de acesso do CT-e referenciado
                 mod_refECF          CHAR(002)          NULL                  ,  -- Modelo do Documento Fiscal
                 nECF_refECF         SMALLINT           NULL                  ,  -- Número de ordem sequencial do ECF
                 nCOO_refECF         INT                NULL                  --,  -- Número do Contador de Ordem de Operação - COO
				 --CONSTRAINT PK_NFE PRIMARY KEY NONCLUSTERED (CPFJ, FILIAL, nIdNFe)
        )
        CREATE UNIQUE CLUSTERED INDEX IX_NFE02_01 ON NFe.NFE02(CPFJ, FILIAL, nIdNFe);
    END
    
    IF OBJECT_ID('NFe.Det02') IS NULL   --  DROP TABLE NFe.Det;
    BEGIN
    CREATE TABLE NFe.Det02(                -- TAG de grupo do detalhamento de Produtos e Serviços da NF-e
                 CPFJ                      VARCHAR(09)        NOT NULL ,
    			 FILIAL                    VARCHAR(04)        NOT NULL ,
                 nIdNFe                    INT                NOT NULL CONSTRAINT FK_Det_nIdNFe FOREIGN KEY REFERENCES NFe.NFe(nIdNFe) ,                                                                                                       -- Chave primaria da tabela
                 nIdDetItem                INT                NOT NULL IDENTITY(1,1) CONSTRAINT PK_Det  PRIMARY KEY NONCLUSTERED,  -- 
                 infADProd                 VARCHAR(500)       NULL                     ,  -- Informações Adicionais do Produto. **** Tabela normalizada
                 cProd                     VARCHAR(060)       NOT NULL CONSTRAINT FK_Det_cProd FOREIGN KEY REFERENCES NFe.Prod(cProd)                                                                                                          ,  -- Código do produto ou serviço
                 cEAN                      VARCHAR(014)       NOT NULL                 ,  -- GTIN (Global Trade Item Number) do produto, antigo código EAN ou código de barras.
                 xProd                     VARCHAR(120)       NOT NULL                 ,  -- Descrição do produto ou serviço
                 NCM                       VARCHAR(008)       NOT NULL                 ,  -- Código NCM com 8 dígitos ou 2 dígitos (gênero)
                 EXTIPI                    VARCHAR(003)       NULL                     ,  -- EX_TIPI
                 CFOP                      DECIMAL(004)       NOT NULL                 ,  -- Código Fiscal de Operações e Prestações
                 uCOM                      VARCHAR(006)       NOT NULL                 ,  -- Unidade Comercial
                 qCOM                      DECIMAL(11,4)      NOT NULL                 ,  -- Quantidade Comercial
                 vUnCom                    DECIMAL(21,10)     NOT NULL                 ,  -- Valor Unitário de comercialização
                 vProd                     DECIMAL(15,2)      NOT NULL                 ,  -- Valor Total Bruto dos Produtos ou Serviços
                 cEANTrib                  VARCHAR(014)       NOT NULL                 ,  -- GTIN (Global Trade Item Number) da unidade tributável, antigo código EAN ou código de barras.
                 uTrib                     VARCHAR(006)       NOT NULL                 ,  -- Unidade Tributável
                 qTrib                     DECIMAL(11,4)      NOT NULL                 ,  -- Quantidade Tributável
                 vUnTrib                   DECIMAL(21,10)     NULL                     ,  -- Valor Unitário de tributação
                 vFrete                    DECIMAL(15,2)      NULL                     ,  -- Valor Total do Frete
                 vSeg                      DECIMAL(15,2)      NULL                     ,  -- Valor Total do Seguro
                 vDesc                     DECIMAL(15,2)      NULL                     ,  -- Valor do Desconto
                 vOutro_item               DECIMAL(15,2)      NULL                     ,  -- Outras despesas acessórias
                 indTot                    TINYINT            NOT NULL                 ,  -- Indica se valor do Item (vProd) entra no valor total da NF-e (vProd)
                 nTipoItem                 TINYINT            NOT NULL                 ,  -- Número do tipo do Item
                 dProd                     TINYINT            NULL                     ,  -- Destaque de Produtos Perigosos
                 xPed_item                 VARCHAR(015)       NULL                     ,  -- Número do Pedido de Compra
                 nItemPed                  VARCHAR(006)       NULL                     ,  -- Item do Pedido de Compra
                 nFCI                      CHAR(036)          NULL                     ,  -- Ficha de Conteúdo de Importação
                 nRECOPI                   VARCHAR(020)       NULL                     ,  -- Número do RECOPI
                 CEST                      VARCHAR(007)       NULL                     ,  -- Código CEST
                 indEscala                 VARCHAR(001)       NULL                     ,  -- Indicador de escala relevante
                 CNPJFab                   VARCHAR(014)       NULL                     ,  -- CNPJ do Fabricante da Mercadoria
                 cBenef                    VARCHAR(020)       NULL                     ,   -- Código de Benefício Fiscal na UF aplicado ao item
    
                 -- Impostos
    			 orig                      TINYINT            NOT NULL                  ,  -- Origem da mercadoria
                 CST                       VARCHAR(004)       NOT NULL                  ,  -- Tributação do ICMS
                 modBC                     TINYINT            NOT NULL                  ,  -- Modalidade de determinação da BC do ICMS
                 vBC                       DECIMAL(15,2)      NOT NULL                  ,  -- Valor da BC do ICMS
                 pICMS                     DECIMAL(5,4)       NOT NULL                  ,  -- Alíquota do Imposto
                 vICMS_icms                DECIMAL(15,2)      NOT NULL                  ,  -- Valor do ICMS
                 modBCST                   TINYINT            NULL                      ,  -- Modalidade de determinação da BC do ICMS ST
                 pMVAST                    DECIMAL(5,2)       NULL                      ,  -- Percentual da margem de valor Adicionado do ICMS ST
                 pRedBCST                  DECIMAL(5,2)       NULL                      ,  -- Percentual da Redução de BC do ICMS ST
                 vBCST                     DECIMAL(15,2)      NULL                      ,  -- Valor da BC do ICMS ST
                 vBCSTRet                  DECIMAL(15,2)      NULL                      ,  -- Valor da BC do ICMS ST retido
                 pICMSST                   DECIMAL(9,4)       NULL                      ,  -- Alíquota do imposto do ICMS ST
                 vICMSST_icms              DECIMAL(15,2)      NULL                      ,  -- Valor do ICMS ST
                 vICMSSTRet                DECIMAL(15,2)      NULL                      ,  -- Valor do ICMS ST retido
                 pRedBC                    DECIMAL(5,2)       NOT NULL                  ,  -- Percentual da Redução de BC
                 motDesICMS                TINYINT            NULL                      ,  -- Motivo da desoneração do ICMS
                 vICMSDeson                DECIMAL(15,2)      NULL                      ,  -- Valor do ICMS desonerado
                 vICMSOp                   DECIMAL(15,2)      NULL                      ,  -- Valor do ICMS da Operação
                 pDif                      DECIMAL(15,2)      NULL                      ,  -- Percentual do Diferimento
                 vICMSDif                  DECIMAL(15,2)      NULL                      ,  -- Valor do ICMS diferido
                 pBCOp                     DECIMAL(5,2)       NOT NULL                  ,  -- Percentual da BC operação própria
                 UFST                      CHAR(002)          NULL                      ,  -- UF para qual é devido o ICMS ST
                 vBCSTDest                 DECIMAL(15,2)      NULL                      ,  -- Valor da BC do ICMS ST da UF destino
                 vICMSSTDest_icms          DECIMAL(15,2)      NULL                      ,  -- Valor do ICMS ST da UF destino
                 pCredSN                   DECIMAL(5,2)       NULL                      ,  -- Alíquota aplicável de cálculo do crédito (Simples Nacional).
                 vCredICMSSN               DECIMAL(15,2)      NULL                      ,  -- Valor crédito do ICMS que pode ser aproveitado nos termos do art. 23 da LC 123 (Simples Nacional)
                 pFCP                      DECIMAL(8,4)       NOT NULL                  ,  -- Percentual do Fundo de Combate à Pobreza (FCP)
                 vFCP                      DECIMAL(16,2)      NOT NULL                  ,  -- Valor do Fundo de Combate à Pobreza (FCP)
                 vBCFCP                    DECIMAL(16,2)      NOT NULL                  ,  -- Valor da Base de Cálculo do Fundo de Combate à Pobreza (FCP)
                 vBCFCPST                  DECIMAL(16,2)      NOT NULL                  ,  -- Valor da Base de Cálculo do FCP retido por Substituição Tributária
                 pFCPST                    DECIMAL(5,2)       NOT NULL                  ,  -- Percentual do FCP retido por Substituição Tributária
                 vFCPST                    DECIMAL(15,2)      NOT NULL                  ,  -- Valor do FCP retido por Substituição Tributária
                 pST                       DECIMAL(8,4)       NOT NULL                  ,  -- Alíquota suportada pelo Consumidor Final
                 vICMSSubstituto           DECIMAL(16,2)      NULL                      ,  -- Valor do ICMS próprio do Substituto
                 vBCFCPSTRet               DECIMAL(16,2)      NOT NULL                  ,  -- Valor da Base de Cálculo do FCP retido anteriormente por ST
                 pFCPSTRet                 DECIMAL(8,4)       NOT NULL                  ,  -- Percentual do FCP retido anteriormente por Substituição Tributária
                 vFCPSTRet                 DECIMAL(16,2)      NOT NULL                  ,  -- Valor do FCP retido por Substituição Tributária
                 GerarICMSST               CHAR(001)          NULL                      ,  -- Indica se irá gerar o grupo ICMS ST - Grupo de Repasse de ICMS ST retido anteriormente em operações interestaduais com repasses através do Substituto Tributário
                 pRedBCEfet                DECIMAL(8,4)       NOT NULL                  ,  -- Percentual de redução da base de cálculo efetiva
                 vBCEfet                   DECIMAL(16,2)      NOT NULL                  ,  -- Valor da base de cálculo efetiva
                 pICMSEfet                 DECIMAL(8,4)       NOT NULL                  ,  -- Alíquota do ICMS efetiva
                 vICMSEfet                 DECIMAL(16,2)      NOT NULL                  ,  -- Valor do ICMS efetivo
                 
    			 -- IPI
                 CNPJProd                  VARCHAR(014)       NULL                      ,  -- CNPJ do produtor da mercadoria, quando diferente do emitente. Somente para os casos de exportação direta ou indireta.
                 cSelo                     VARCHAR(060)       NULL                      ,  -- Código do selo de controle IPI
                 qSelo                     DECIMAL(12)        NULL                      ,  -- Quantidade de selo de controle
                 cEnq                      CHAR(3)            NOT NULL                                                                                                           ,  -- Código de Enquadramento Legal do IPI
                 
                 -- CREATE TABLE NFe.Imposto_Cstipi(            -- Grupo de Classificação Fiscal do IPI
                 CST_IPI                   CHAR(002)          NOT NULL                                                                                                           ,  -- Código da situação tributária do IPI
                 vBC_IPI                   DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor da BC do IPI
                 qUnid_IPI                 DECIMAL(16,4)      NULL                                                                                                           ,  -- Quantidade total na unidade padrão para tributação (somente para os produtos tributados por unidade)
                 vUnid_IPI                 DECIMAL(15,4)      NULL                                                                                                           ,  -- Valor por Unidade Tributável
                 pIPI                      DECIMAL(5,2)       NULL                                                                                                           ,  -- Alíquota do IPI
                 vIPI                      DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor do IPI
                 
                 -- CREATE TABLE NFe.Imposto_Ii(         -- II Imposto de importação
                 vBC_imp                   DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor da BC do Imposto de Importação
                 vDespAdu                  DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor das despesas aduaneiras
                 vII                       DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor do Imposto de Importação
                 vIOF                      DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor do Imposto sobre Operações Financeiras
                 
                 -- CREATE TABLE NFe.Imposto_Pis(                                                                                                                                                        -- TAG de grupo do PIS
                 CST_pis                   CHAR(002)                                                                                                                     ,  -- Código de Situação Tributária do PIS
                 vBC_pis                   DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor da Base de Cálculo do PIS
                 pPIS                      DECIMAL(5,2)       NULL                                                                                                       ,  -- Alíquota do PIS (em percentual)
                 vPIS                      DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor do PIS
                 qBCprod_pis               DECIMAL(16,4)      NULL                                                                                                       ,  -- Quantidade Vendida
                 vAliqProd_pis             DECIMAL(15,4)      NULL                                                                                                       ,  -- Alíquota do PIS (em reais)
                 
                 -- CREATE TABLE NFe.Cofins(   -- TAG de grupo do COFINS
                 CST_cofins                CHAR(002)          NULL                                                                                                       ,  -- Código de Situação Tributária do COFINS
                 vBC_cofins                DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor da Base de Cálculo da COFINS
                 pCOFINS                   DECIMAL(5,2)       NULL                                                                                                       ,  -- Alíquota da COFINS (em percentual)
                 vCOFINS                   DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor do COFINS
                 qBCProd_cofins            DECIMAL(16,4)      NULL                                                                                                       ,  -- Quantidade Vendida
                 vAliqProd_cofins          DECIMAL(15,4)      NULL                                                                                                       ,  -- Alíquota do COFINS (em reais)
                 
                 -- CREATE TABLE NFe.Cofinsst(   -- TAG do grupo de COFINS Substituição Tributária
                 vBC_cofins_ST             DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor da Base de Cálculo da COFINS
                 pCOFINS_cofins_ST         DECIMAL(15,2)      NULL                                                                                                       ,  -- Alíquota da COFINS (em percentual)
                 qBCProd_cofins_ST         DECIMAL(16,4)      NULL                                                                                                       ,  -- Quantidade Vendida
                 vAliqProd_cofins_ST       DECIMAL(15,4)      NULL                                                                                                       ,  -- Alíquota do COFINS (em reais)
                 vCOFINS_cofins_ST         DECIMAL(15,2)      NOT NULL                                                                                                   ,  -- Valor do COFINS
                 
                 -- CREATE TABLE NFe.Issqn(  -- TAG do grupo do ISSQN
                 vBC_issqn                 DECIMAL(15,2)      NOT NULL                                                                                                   ,  -- Valor da Base de Cálculo do ISSQN
                 vAliq                     DECIMAL(5,2)       NOT NULL                                                                                                   ,  -- Alíquota do ISSQN
                 vISSQN                    DECIMAL(15,2)      NOT NULL                                                                                                   ,  -- Valor do ISSQN
                 cMunFg_issqn              DECIMAL(7)         NOT NULL                                                                                                   ,  -- Código do município de ocorrência do fato gerador do ISSQN
                 cListServ                 VARCHAR(005)       NOT NULL                                                                                                   ,  -- Código da Lista de Serviços
                 vDeducao                  DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor dedução para redução da Base de Cálculo
                 vOutro_issqn              DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor outras retenções
                 vDescIncond               DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor desconto incondicionado
                 vDescCond                 DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor desconto condicionado
                 indISSRet                 TINYINT            NOT NULL                                                                                                   ,  -- Indicador de ISS Retido
                 vISSRet                   DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor de Retenção do ISS
                 indISS                    TINYINT            NOT NULL                                                                                                   ,  -- Indicador da exigibilidade do ISS
                 cServico                  VARCHAR(020)       NULL                                                                                                       ,  -- Código do serviço prestado dentro do município
                 cMun_issqn                DECIMAL(7)         NULL                                                                                                       ,  -- Código do município de incidência do imposto
                 cPais_issqn               DECIMAL(4)         NULL                                                                                                       ,  -- Código do País onde o serviço foi prestado
                 nProcesso                 VARCHAR(030)       NULL                                                                                                       ,  -- Número do processo judicial ou administrativo de suspensão da exigibilidade
                 indIncentivo              TINYINT            NOT NULL                                                                                                   ,  -- Indicador de incentivo Fiscal
                 
                 -- CREATE TABLE NFe.Icmsufdest(                                                                                                                                                         -- TAG de Grupo de Informação do ICMS de partilha com a UF do destinatário na operação interestadual
                 vBCUFDest                 DECIMAL(15,2)      NOT NULL                                                                                                   ,  -- Valor da BC do ICMS na UF do destinatário
                 pFCPUFDest                DECIMAL(7,4)       NULL                                                                                                       ,  -- Percentual do ICMS relativo ao Fundo de Combate à Pobreza (FCP) na UF de destino
                 pICMSUFDest               DECIMAL(7,4)       NOT NULL                                                                                                   ,  -- Alíquota interna da UF do destinatário
                 pICMSInter                DECIMAL(7,4)       NOT NULL                                                                                                   ,  -- Alíquota interestadual das UF envolvidas
                 pICMSInterPart            DECIMAL(7,4)       NOT NULL                                                                                                   ,  -- Percentual provisório de partilha entre os Estados
                 vFCPUFDest                DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor do ICMS relativo ao Fundo de Combate à Pobreza (FCP) da UF de destino
                 vICMSUFDest               DECIMAL(15,2)      NOT NULL                                                                                                   ,  -- Valor do ICMS de partilha para a UF do destinatário
                 vICMSUFRemet              DECIMAL(15,2)      NOT NULL                                                                                                   ,  -- Valor do ICMS de partilha para a UF do remetente
                 vBCFCPUFDest              DECIMAL(15,2)      NULL                                                                                                       ,  -- Valor da Base de Cálculo do FCP na UF de destino
                 
                 -- CREATE TABLE NFe.Impostodevol(                                                                                                                       -- TAG de Grupo de Informações do Imposto Devolvido
                 nIdItem                   INT                NOT NULL                                                                                                   ,  -- Chave primaria da tabela (nIdNFe + nIdItem)
                 pDevol                    DECIMAL(3,2)       NOT NULL                                                                                                   ,  -- Percentual da mercadoria devolvida
                 
                 --CREATE TABLE NFe.Ipidevol(                                                                                                                                                           -- TAG de Grupo de Informação do IPI Devolvido
                 vIPIDevol                 DECIMAL(15,2)      NOT NULL                                                                                                      , -- Valor do IPI Devolvido
                 
                 -- CREATE TABLE NFe.Total(                                                                                                                                                              -- TAG de grupo de Valores Totais da NF-e
                 vBC_ttlnfe                DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Base de Cálculo do ICMS
                 vICMS_ttlnfe              DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do ICMS
                 vICMSDeson_ttlnfe         DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Total do ICMS Desonerado
                 vBCST_ttlnfe              DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Base de Cálculo do ICMS ST
                 vST_ttlnfe                DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do ICMS ST
                 vProd_ttlnfe              DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total dos produtos e serviços
                 vFrete_ttlnfe             DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do Frete
                 vSeg_ttlnfe               DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do Seguro
                 vDesc_ttlnfe              DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do Desconto
                 vII_ttlnfe                DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do II
                 vIPI_ttlnfe               DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do IPI
                 vPIS_ttlnfe               DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total do PIS
                 vCOFINS_ttlnfe            DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor do COFINS
                 vOutro                    DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Outras Despesas acessórias
                 vNF                       DECIMAL(15,2)      NOT NULL                                                                                                           ,  -- Valor Total da NF-e
                 vTotTrib_ttlnfe           DECIMAL(16,2)      NULL                                                                                                           ,  -- Valor aproximado total de tributos federais, estaduais e municipais.
                 vFCPUFDest_ttlnfe         DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor total do ICMS relativo ao Fundo de Combate à Pobreza (FCP) da UF de destino
                 vICMSUFDest_ttlnfe        DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor total do ICMS de partilha para a UF do destinatário
                 vICMSUFRemet_ttlnfe       DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor total do ICMS de partilha para a UF do remetente
                 vFCP_ttlnfe               DECIMAL(16,2)      NOT NULL                                                                                                           ,  -- Valor Total do FCP (Fundo de Combate à Pobreza)
                 vFCPST_ttlnfe             DECIMAL(16,2)      NOT NULL                                                                                                           ,  -- Valor Total do FCP (Fundo de Combate à Pobreza) retido por substituição tributária
                 vFCPSTRet_ttlnfe          DECIMAL(16,2)      NOT NULL                                                                                                           ,  -- Valor Total do FCP (Fundo de Combate à Pobreza) retido anteriormente por substituição tributária
                 vIPIDevol_ttlnfe          DECIMAL(16,2)      NOT NULL                                                                                                           ,  -- Valor Total do IPI devolvido
                 
                 -- CREATE TABLE NFe.Issqntot(                                                                                                                                                           -- TAG de grupo de Valores Totais referentes ao ISSQN
                 vServ                     DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Total dos Serviços sob não incidência ou não tributados pelo ICMS
                 vBC_ttlnfe_iss            DECIMAL(15,2)      NULL                                                                                                           ,  -- Base de Cálculo do ISS
                 vISS                      DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Total do ISS
                 vPIS_servttlnfe           DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor do PIS sobre serviços
                 vCOFINS_servttlnfe        DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor do COFINS sobre serviços
                 dCompet                   DATETIME           NOT NULL                                                                                                           ,  -- Data da prestação do serviço
                 vDeducao_servttlnfe       DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor dedução para redução da Base de Cálculo
                 vOutro_servttlnfe         DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor outras retenções
                 vDescIncond_servttlnfe    DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor desconto incondicionado
                 vDescCond_servttlnfe      DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor desconto condicionado
                 vISSRet_servttlnfe        DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor total retenção ISS
                 cRegTrib                  TINYINT            NULL                                                                                                           ,   -- Código do Regime Especial de Tributação
                 
                 -- CREATE TABLE NFe.Rettrib(                                                                                                                                   -- TAG de grupo de Retenções de Tributos
                 vRetPIS                   DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Retido de PIS
                 vRetCOFINS_servttlnfe     DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Retido de COFINS
                 vRetCSLL                  DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Retido de CSLL
                 vBCIRRF                   DECIMAL(15,2)      NULL                                                                                                           ,  -- Base de Cálculo do IRRF
                 vIRRF                     DECIMAL(15,2)      NULL                                                                                                           ,  -- Valor Retido de IRRF
                 vBCRetPrev                DECIMAL(15,2)      NULL                                                                                                           ,  -- Base de Cálculo da Retenção da Previdência Social
                 vRetPrev                  DECIMAL(15,2)      NULL                                                                                                             -- Valor da Retenção da Previdência Social
        )
        CREATE UNIQUE CLUSTERED INDEX IX_DET02_01 ON NFe.Det02(CPFJ, FILIAL, nIdNFe, nIdDetItem)
	END;

	SELECT Top 1000 * FROM NFe.NFe02;
	SELECT Top 1000 * FROM NFe.Det02;
	SELECT Top 1000 * FROM NFe.Prod;

END    
    