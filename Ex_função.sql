CREATE DATABASE ExEmpresa;
GO
USE ExEmpresa;

CREATE TABLE Funcionario (
    Codigo INT PRIMARY KEY,
    Nome VARCHAR(100),
    Salario DECIMAL(10, 2)
);


CREATE TABLE Dependente (
    Codigo_Dep INT PRIMARY KEY,
    Codigo_Funcionario INT,
    Nome_Dependente VARCHAR(100),
    Salario_Dependente DECIMAL(10, 2),
    FOREIGN KEY (Codigo_Funcionario) REFERENCES Funcionario(Codigo)
);

INSERT INTO Funcionario (Codigo, Nome, Salario) VALUES
(1, 'João', 3000.00),
(2, 'Maria', 3500.00),
(3, 'Pedro', 2800.00);

INSERT INTO Dependente (Codigo_Dep, Codigo_Funcionario, Nome_Dependente, Salario_Dependente) VALUES
(101, 1, 'Ana', 1000.00),
(102, 1, 'Paulo', 3000.00),
(103, 2, 'Carla', 1000.00),
(104, 3, 'Mariana', 1000.00),
(105, 3, 'Rafael', 1000.00);


SELECT * FROM Funcionário;
SELECT * FROM Dependente;

--a) Código no Github ou Pastebin de uma Function que Retorne uma tabela:
--(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)

CREATE FUNCTION fn_tabela()
RETURNS @tabela TABLE (
Nome VARCHAR(100),
Nome_Dependente VARCHAR(100),
Salario DECIMAL(10, 2),
Salario_Dependente DECIMAL(10, 2)
) 
BEGIN

    INSERT INTO @tabela(Nome, Salario, Nome_Dependente, Salario_Dependente)
	     SELECT F.nome, F.Salario, D.Nome_Dependente, D.Salario_Dependente
		 FROM Funcionario F
		 INNER JOIN Dependente D ON D.Codigo_Funcionario = F.Codigo;

		 	RETURN
END

SELECT * FROM fn_tabela()

--b) Código no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Salários dos
--dependentes, mais a do funcionário.

CREATE FUNCTION fn_salario(@Codigo INT)
RETURNS DECIMAL(12, 2)
AS
BEGIN
        DECLARE @SalarioTotal DECIMAL(12, 2)


    SELECT @SalarioTotal = ISNULL(SUM(D.Salario_Dependente), 0)
    FROM Dependente D
	INNER JOIN Funcionario F ON F.Codigo = D.Codigo_Funcionario
    WHERE F.Codigo = @Codigo

    SELECT @SalarioTotal = @SalarioTotal + ISNULL(F.Salario, 0)
    FROM Funcionario F
    WHERE F.Codigo = @Codigo

    RETURN @SalarioTotal
END

SELECT dbo.fn_salario(1) AS "TotalSalarios"


CREATE TABLE Produtos (
    codigo INT PRIMARY KEY,
    nome VARCHAR(100),
    valor_unitario DECIMAL(10, 2),
    qtd_estoque INT
);

INSERT INTO Produtos (codigo, nome, valor_unitario, qtd_estoque) VALUES
(1, 'Camiseta', 20.00, 50),
(2, 'Calça Jeans', 50.00, 30),
(3, 'Tênis', 80.00, 20),
(4, 'Sapato Social', 100.00, 10),
(5, 'Shorts', 30.00, 40),
(6, 'Vestido', 70.00, 25);


--a) a partir da tabela Produtos (codigo, nome, valor unitário e qtd estoque), quantos produtos
--estão com estoque abaixo de um valor de entrada

CREATE FUNCTION fn_produtos(@qtd INT)
RETURNS INT
AS
BEGIN
     DECLARE @qtd_menor INT

    SELECT @qtd_menor = COUNT(*)
    FROM Produtos
    WHERE qtd_estoque < @qtd;

    RETURN @qtd_menor
END

SELECT dbo.fn_produtos(20) AS "Quantidade_Menor"


--b) Uma tabela com o código, o nome e a quantidade dos produtos que estão com o estoque
--abaixo de um valor de entrada

CREATE FUNCTION fn_tabelaEstoque(@qtd INT)
RETURNS @tabela TABLE (
codigo INT,
nome VARCHAR(100),
qtd_estoque INT
)
BEGIN
	INSERT INTO @tabela (codigo, nome, qtd_estoque)
		SELECT codigo, nome, qtd_estoque
		FROM Produtos
		WHERE qtd_estoque < @qtd
		RETURN
END

SELECT * FROM fn_tabelaEstoque(40)


CREATE TABLE Cliente (
    Codigo INT PRIMARY KEY,
    Nome VARCHAR(100)
)


INSERT INTO Cliente (Codigo, Nome) VALUES
(1, 'João'),
(2, 'Maria'),
(3, 'Pedro');


CREATE TABLE Produto (
    Codigo INT PRIMARY KEY,
	Codigo_c INT,
    Nome VARCHAR(100),
    Valor DECIMAL(10, 2)
	FOREIGN KEY (Codigo_c) REFERENCES Cliente(codigo)
);


INSERT INTO Produto (Codigo, Nome, Valor, Codigo_c) VALUES
(1, 'Camiseta', 20.00, 2),
(2, 'Calça Jeans', 50.00, 1),
(3, 'Tênis', 80.00, 3),
(4, 'Short', 80.00, 3);


--Criar, uma UDF, que baseada nas tabelas abaixo, retorne
--Nome do Cliente, Nome do Produto, Quantidade e Valor Total, Data de hoje

CREATE FUNCTION fn_tabela_CP()
RETURNS @tabela TABLE (
Nome_cliente VARCHAR(100),
Nome_produto VARCHAR(100),
qtd_p INT,
valot_tot DECIMAL(10, 2),
data_hoje DATE
) 
BEGIN

    INSERT INTO @tabela(Nome_cliente, Nome_produto, qtd_p, valot_tot, data_hoje )
	     SELECT C.nome, P.Nome, COUNT(P.Codigo) AS qtd_p, SUM(P.Valor) AS valor_tot, GETDATE() as data_hoje
		 FROM Cliente C
		 INNER JOIN Produto P ON P.Codigo_c = C.Codigo
		 GROUP BY C.Nome, P.Nome;
		 RETURN
END

SELECT * FROM fn_tabela_CP()