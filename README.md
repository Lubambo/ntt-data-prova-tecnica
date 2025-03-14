# Prova Técnica de Robot Framework NTT Data

Este projeto foi desenvolvido como parte de uma prova técnica para uma vaga de QA na empresa NTT Data. O objetivo foi criar um projeto de automação de testes utilizando o Robot Framework, abrangendo cenários de testes End-to-End (E2E) para o front-end e testes automatizados para a API da aplicação.

## Estrutura do Projeto

O projeto está organizado em duas principais suítes de testes:

- **Front-End:** Contém 3 suítes de testes para validação das funcionalidades da interface do usuário.
- **API:** Contém 3 suítes de testes para validação das operações expostas via API.

### Funcionalidades Testadas

Para ambos, front-end e API, foram criadas suítes de testes para validar as seguintes funcionalidades:

1. **Login**
2. **Operações com Usuário**
3. **Operações com Produto**

## Bibliotecas Utilizadas

### Bibliotecas do Robot Framework

- **SeleniumLibrary:** Utilizada para automação dos testes de front-end.
- **RequestLibrary:** Utilizada para automação dos testes de API.

### Bibliotecas do Python

- **json:** Para manipulação de arquivos JSON.
- **ConfigParser:** Para tornar o arquivo `environment.properties` utilizável dentro do Robot Framework.

## Recursos Adicionais

Foram criados arquivos `.resource` para:

- Auxiliar nas operações envolvendo JSON.
- Realizar operações em elementos HTML `table`.
- Gerar entidades de usuário e produto com valores aleatórios para serem utilizados nos testes.

## Configuração do VS Code

Foi identificado que a variável interna `${EXECDIR}` do Robot Framework não estava funcionando corretamente no VS Code. Para solucionar esse problema, foi necessário adicionar manualmente a propriedade:

```json
"robot.variables": {
  "EXECDIR": "${workspaceFolder}"
}
```

nas configurações da IDE.

## Execução dos Testes

Para executar as suítes de testes, utilize os seguintes comandos:

### Testes de Front-End

- Testes relacionados à página de login:

```bash
robot -d results tests/front-end/Login_Tests.robot
```

- Testes relacionados às operações com usuário:

```bash
robot -d results tests/front-end/User_Operations_Tests.robot
```

- Testes relacionados às operações com produto:

```bash
robot -d results tests/front-end/Product_Operations_Tests.robot
```

### Testes de API

- Testes relacionados ao endpoint de login:

```bash
robot -d results tests/api/Login_Endpoint_Tests.robot
```

- Testes relacionados ao endpoint de usuários:

```bash
robot -d results tests/api/User_Endpoint_Tests.robot
```

- Testes relacionados ao endpoint de produtos:

```bash
robot -d results tests/api/Product_Endpoint_Tests.robot
```
