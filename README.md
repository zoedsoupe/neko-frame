# NekoFrame - Criador de Cartas para "Gatoversos: a rinha"

Um criador de cartas interativo desenvolvido especialmente para o jogo de cartas **Gatoversos: a rinha**, criado pela [Pandora](https://instagram.com/pandora.wmv). Esta aplicação permite criar cartas personalizadas com visual profissional e exportar em alta qualidade para impressão.

## Sobre o "Gatoversos: a rinha"

Jogo de cartas estratégico com temática felina onde cada jogador começa com 21 pontos de energia e possui um deck de 50 cartas principais mais 20 cartas de recursos. O objetivo é ser o último jogador com energia restante.

### Tipos de Carta

- **Gatos**: Domésticos, Divindades, Robôs, Grandes Felinos - as criaturas principais do jogo
- **Tutores**: Líderes únicos do deck que ficam na zona de descanso e podem ser invocados pagando energia
- **Criaturinhas**: Qualquer criatura que não seja gato ou tutor, com pontos de briga e coragem
- **Auxílios**: Efeitos instantâneos que geralmente são descartados após o uso
- **Trecos**: Objetos com efeitos que tendem a permanecer no campo

### Sistema de Recursos

O jogo utiliza diferentes tipos de recursos para invocar cartas:
- **Suprimento Comum**: Recurso básico mais abundante
- **Favor**: Recurso social para cartas especiais
- **Dinheiro**: Recurso econômico para compras e contratações
- **Suprimento Especial**: Recurso raro com destaque visual especial
- **Energia**: Recurso vital com destaque visual especial

## Funcionalidades do NekoFrame

### Criação de Cartas
- Preview em tempo real da carta sendo criada
- Campos dinâmicos para nome, tipo e classe personalizada
- Sistema visual de custos com badges coloridos
- Upload de imagem para a arte da carta
- Editor de descrição com formatação básica

### Padrões Profissionais
- Dimensões padrão Magic: 63.5×88.9mm para compatibilidade com sleeves
- Exportação em 600 DPI para impressão profissional
- Layout responsivo com preview escalado para facilitar edição

### Recursos Técnicos
- Interface web em Phoenix LiveView para atualizações instantâneas
- Exportação usando HTML2Canvas para máxima qualidade
- Sistema de upload integrado para imagens
- CSS customizado com efeitos visuais apropriados

## Como Usar

1. **Instale as dependências**:
   ```bash
   mix setup
   ```

2. **Inicie o servidor**:
   ```bash
   mix phx.server
   ```

3. **Acesse no navegador**: [localhost:4000](http://localhost:4000)

4. **Crie sua carta**:
   - Preencha nome, tipo e classe personalizada (ex: "Gato - Doméstico")
   - Adicione uma imagem para a arte da carta
   - Configure os custos de recursos usando os controles
   - Escreva a descrição dos efeitos e habilidades
   - Visualize o preview em tempo real
   - Exporte em alta qualidade quando estiver satisfeito

## Exemplo de Carta do Universo GatarãO

```
Nome: Ísis, Gata Mãe
Tipo: Gato - Divindade
Custo: 2 Suprimento + 1 "Carne"
Briga: 1 | Coragem: 1

Descrição:
Sacrificar 1 — Mande uma carta do seu campo para o cemitério
e chame essa carta para o campo sem pagar seu custo.
Ao entrar, restaura a coragem de todas as cartas possíveis.
Quando usar uma carta de auxílio você pode pagar 1 "Carne"
para duplicá-la.
```

## Tecnologias

- **Elixir** com **Phoenix Framework** para o backend
- **Phoenix LiveView** para interatividade em tempo real
- **HTML2Canvas** para exportação de alta qualidade
- **CSS3** com layouts responsivos e animações

---

*Criado para dar vida ao jogo "Gatoversos: a rinha" da Pandora*
