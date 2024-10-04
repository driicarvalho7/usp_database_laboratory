/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package aula05.oracleinterface;

import java.awt.Component;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author junio
 */
public class DBFuncionalidades {
    Connection connection;
    Statement stmt;
    ResultSet rs;
    JTextArea jtAreaDeStatus;
    
    private String[][] getDadosTabela(String nomeTabela, int numColunas) {
        String s = "";
        try {
            // Consulta para selecionar todos os dados da tabela
            s = "SELECT * FROM " + nomeTabela;
            stmt = connection.createStatement();
            rs = stmt.executeQuery(s);

            // Criar uma lista para armazenar as linhas da tabela
            ArrayList<String[]> linhasList = new ArrayList<>();

            // Iterar sobre o ResultSet e armazenar os dados dinamicamente
            while (rs.next()) {
                String[] linha = new String[numColunas];
                for (int i = 1; i <= numColunas; i++) {
                    String valor = rs.getString(i);
                    linha[i - 1] = (valor != null) ? valor : "[null]";
                }
                linhasList.add(linha);
            }

            // Converter a lista de linhas para um array bidimensional
            String[][] dados = linhasList.toArray(new String[0][0]);
            rs.close();
            stmt.close();

            return dados; // Retorna os dados da tabela
        } catch (SQLException ex) {
            jtAreaDeStatus.setText("Erro ao recuperar dados da tabela: " + nomeTabela + " com a consulta: \"" + s + "\"");
        }
        return new String[0][0]; // Retorna um array vazio em caso de erro
    }
    
    private StringBuilder getAllInformationColunas(String nomeTabela) {
        StringBuilder metaInfo = new StringBuilder();
        try {
            String s = "SELECT column_id, column_name, data_type, data_length, nullable " +
                "FROM all_tab_columns WHERE table_name = '" + nomeTabela.toUpperCase() + "' ORDER BY column_id";

            stmt = connection.createStatement();
            rs = stmt.executeQuery(s);

            metaInfo.append("Metadados da Tabela: ").append(nomeTabela).append("\n");
            
            while (rs.next()) {
                int idColuna = rs.getInt("COLUMN_ID");
                String nomeColuna = rs.getString("COLUMN_NAME");
                String tipoColuna = rs.getString("DATA_TYPE");
                int tamanhoColuna = rs.getInt("DATA_LENGTH");
                String aceitaNulo = rs.getString("NULLABLE");

                metaInfo.append("ID: ").append(idColuna)
                        .append(" | Coluna: ").append(nomeColuna)
                        .append(" | Tipo: ").append(tipoColuna)
                        .append(" | Tamanho: ").append(tamanhoColuna)
                        .append(" | Aceita Nulo: ").append(aceitaNulo.equals("Y") ? "Sim" : "Não")
                        .append("\n");
            }
        } catch (SQLException ex) {
            jtAreaDeStatus.setText("Erro ao obter colunas da tabela: " + ex.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
            } catch (SQLException e) {
                jtAreaDeStatus.setText("Erro ao fechar recursos: " + e.getMessage());
            }
        }
        return metaInfo;
    }
    
    private String[] getNomeColunas(String nomeTabela) {
        ArrayList<String> colunasList = new ArrayList<>();
        try {
            String s = "SELECT column_name FROM all_tab_columns WHERE table_name = '" + nomeTabela.toUpperCase() + "' ORDER BY column_id";
            stmt = connection.createStatement();
            rs = stmt.executeQuery(s);
            while (rs.next()) {
                colunasList.add(rs.getString("COLUMN_NAME"));
            }
        } catch (SQLException ex) {
            jtAreaDeStatus.setText("Erro ao obter colunas da tabela: " + ex.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
            } catch (SQLException e) {
                jtAreaDeStatus.setText("Erro ao fechar recursos: " + e.getMessage());
            }
        }
        return colunasList.toArray(String[]::new);
    }
    
    public DBFuncionalidades(JTextArea jtaTextArea){
        jtAreaDeStatus = jtaTextArea;
    }
    
    public boolean conectar(){       
        try {
            DriverManager.registerDriver (new oracle.jdbc.OracleDriver());
            connection = DriverManager.getConnection(
                    "jdbc:oracle:thin:@orclgrad2.icmc.usp.br:1521/pdb_junior.icmc.usp.br",
                    "L13692400",
                    "L13692400");
            return true;
        } catch(SQLException ex){
            jtAreaDeStatus.setText("Problema: verifique seu usuário e senha");
        }
        return false;
    }
    
    public void pegarNomesDeTabelas(JComboBox jc){
        String s = "";
        try {
            s = "SELECT table_name FROM user_tables ORDER BY table_name ASC";
            stmt = connection.createStatement();
            rs = stmt.executeQuery(s);
            while (rs.next())
                jc.addItem(rs.getString("table_name"));         
            stmt.close();
        } catch (SQLException ex) {
            jtAreaDeStatus.setText("Erro na consulta: \"" + s + "\"");
        }        
    }
    
    public String[] getTablesName() {
        ArrayList<String> table = new ArrayList<>();
        try {
            String s = "SELECT table_name FROM user_tables ORDER BY table_name ASC";
            stmt = connection.createStatement();
            rs = stmt.executeQuery(s);
            while (rs.next()) {
                String t = rs.getString("TABLE_NAME");
                table.add(t);
            }
        } catch (SQLException ex) {
            jtAreaDeStatus.setText("Erro ao obter colunas da tabela: " + ex.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
            } catch (SQLException e) {
                jtAreaDeStatus.setText("Erro ao fechar recursos: " + e.getMessage());
            }
        }
        return table.toArray(String[]::new);
    }
    
    public void exibeDados(JTable jt, String nomeTabela){
        try {
            // Recebe todas as informações das colunas
            StringBuilder metaInfo = getAllInformationColunas(nomeTabela);
            
            // Recebe o nome das colunas
            String[] colunas = getNomeColunas(nomeTabela);

            // Recebe os dados da tabela
            String[][] dados = getDadosTabela(nomeTabela, colunas.length);
            
            DefaultTableModel model = (DefaultTableModel) jt.getModel();
            model.setDataVector(dados, colunas);
            
            jtAreaDeStatus.setText(metaInfo.toString());
            rs.close();
            stmt.close();
        } catch (SQLException ex) {
            jtAreaDeStatus.setText("Erro ao recuperar metadados da tabela: " + nomeTabela);
        }
    }
    
    public void inserirDados(String nomeTabela, JPanel painelDeInsercao) {
        try {
            StringBuilder sql = new StringBuilder("INSERT INTO " + nomeTabela + " (");
            StringBuilder valores = new StringBuilder(" VALUES (");

            Component[] componentes = painelDeInsercao.getComponents();
            ArrayList<String> colunas = new ArrayList<>();
            ArrayList<String> valoresInseridos = new ArrayList<>();

            // Itera sobre os componentes do painel para obter os valores
            for (int i = 0; i < componentes.length; i += 2) {
                if (componentes[i] instanceof JLabel && componentes[i + 1] instanceof JTextField) {
                    JLabel label = (JLabel) componentes[i];
                    JTextField campoTexto = (JTextField) componentes[i + 1];

                    String nomeColuna = label.getText();
                    String valor = campoTexto.getText();

                    // Verifica se a coluna é do tipo DATE e aplica o TO_DATE
                    if (ehColunaData(nomeTabela, nomeColuna)) {
                        // Certifique-se de que a data está no formato correto
                        valoresInseridos.add("TO_DATE('" + valor + "', 'YYYY-MM-DD')");
                    } else {
                        valoresInseridos.add("'" + valor + "'");
                    }
                    colunas.add(nomeColuna);
                } else if (componentes[i] instanceof JLabel && componentes[i + 1] instanceof JComboBox) {
                    JLabel label = (JLabel) componentes[i];
                    JComboBox comboBox = (JComboBox) componentes[i + 1];

                    String nomeColuna = label.getText();
                    String valorSelecionado = (String) comboBox.getSelectedItem();
                    valoresInseridos.add("'" + valorSelecionado + "'");
                    colunas.add(nomeColuna);
                }
            }

            // Constrói o comando SQL
            sql.append(String.join(", ", colunas));
            sql.append(")");
            valores.append(String.join(", ", valoresInseridos));
            valores.append(")");

            String comandoSql = sql.toString() + valores.toString();
            stmt = connection.createStatement();
            stmt.executeUpdate(comandoSql);
            jtAreaDeStatus.setText("Dados inseridos com sucesso!");

        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao inserir dados: " + e.getMessage());
        }
    }
    
    public void exportarCsv(String nomeTabela) {
        FileWriter csvWriter = null;
        try {
            // Recuperar colunas e dados da tabela
            String[] colunas = getNomeColunas(nomeTabela);
            String[][] dados = getDadosTabela(nomeTabela, colunas.length);

            // Gerar o nome do arquivo CSV
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String caminhoArquivo = nomeTabela + "_" + timestamp + ".csv";  // Arquivo no diretório do projeto

            // Criar o FileWriter para escrever no arquivo CSV com codificação UTF-8
            csvWriter = new FileWriter(caminhoArquivo, StandardCharsets.UTF_8);

            // Escrever as colunas no arquivo CSV
            for (int i = 0; i < colunas.length; i++) {
                csvWriter.append(colunas[i]);
                if (i < colunas.length - 1) {
                    csvWriter.append(",");
                }
            }
            csvWriter.append("\n");

            // Configurar o formato de número e data de acordo com o locale da máquina
            Locale locale = Locale.getDefault(); // Usar o locale da máquina
            NumberFormat numberFormat = NumberFormat.getInstance(locale);
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd", locale);  // Formato de data sem hora

            // Escrever os dados no arquivo CSV
            for (String[] linha : dados) {
                for (int i = 0; i < linha.length; i++) {
                    String valor = linha[i];

                    // Verificar se o valor é numérico e formatar
                    try {
                        double num = Double.parseDouble(valor);
                        valor = numberFormat.format(num);  // Formatar com separador decimal do locale
                    } catch (NumberFormatException e) {
                        // Se não for número, verificar se é data e formatar
                        try {
                            Date data = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(valor); // Exemplo de formato de datetime do banco
                            valor = dateFormat.format(data);  // Exportar apenas a data
                        } catch (ParseException ex) {
                            // Se não for nem número nem data, manter o valor original
                        }
                    }

                    // Adicionar o valor formatado ao CSV
                    csvWriter.append(valor);
                    if (i < linha.length - 1) {
                        csvWriter.append(",");
                    }
                }
                csvWriter.append("\n");
            }

            jtAreaDeStatus.setText("Exportação para CSV concluída: " + caminhoArquivo);

        } catch (IOException e) {
            jtAreaDeStatus.setText("Erro ao exportar para CSV: " + e.getMessage());
        } finally {
            if (csvWriter != null) {
                try {
                    csvWriter.close();
                } catch (IOException e) {
                    jtAreaDeStatus.setText("Erro ao fechar o arquivo CSV: " + e.getMessage());
                }
            }
        }
    }
    
    public void prepararInsercaoDeDados(JPanel painelDeInsercao, String nomeTabela) {
        painelDeInsercao.removeAll(); // Limpar o painel antes de adicionar novos campos

        String[] colunas = getNomeColunas(nomeTabela);

        painelDeInsercao.setLayout(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5); // Margens entre os componentes

        int row = 0;  // Contador de linhas para o GridBagLayout

        for (String coluna : colunas) {
            JLabel label = new JLabel(coluna);
            gbc.gridx = 0;
            gbc.gridy = row;
            gbc.anchor = GridBagConstraints.WEST;
            painelDeInsercao.add(label, gbc); // Adiciona o JLabel no GridBagLayout

            // Verifica se a coluna é chave primária
            if (ehChavePrimaria(nomeTabela, coluna) || ehColunaUnique(nomeTabela, coluna)) {
                // Para chaves primárias, usamos um JTextField
                JTextField campoTexto = new JTextField(20);  // Campo de texto de tamanho 20
                gbc.gridx = 1;
                gbc.gridy = row;
                gbc.fill = GridBagConstraints.HORIZONTAL;
                painelDeInsercao.add(campoTexto, gbc); // Adiciona o JTextField
            }
            // Verifica se a coluna tem restrições CHECK
            else if (temRestricaoCheck(nomeTabela, coluna)) {
                JComboBox<String> comboBox = new JComboBox<>();
                String[] valoresCheck = getValoresCheck(nomeTabela, coluna); // Obtém os valores permitidos
                for (String valor : valoresCheck) {
                    comboBox.addItem(valor.trim());
                }
                gbc.gridx = 1;
                gbc.gridy = row;
                gbc.fill = GridBagConstraints.HORIZONTAL;
                painelDeInsercao.add(comboBox, gbc); // Adiciona o JComboBox
            } 
            // Verifica se a coluna é chave estrangeira (FK)
            else if (ehChaveEstrangeira(nomeTabela, coluna)) {
                JComboBox<String> comboBox = new JComboBox<>();
                String[] valoresFK = getValoresChaveEstrangeira(nomeTabela, coluna); // Obtém os valores FK
                for (String valor : valoresFK) {
                    comboBox.addItem(valor.trim());
                }
                gbc.gridx = 1;
                gbc.gridy = row;
                gbc.fill = GridBagConstraints.HORIZONTAL;
                painelDeInsercao.add(comboBox, gbc); // Adiciona o JComboBox para FK
            } 
            // Para outras colunas, usamos JTextField
            else {
                JTextField campoTexto = new JTextField(20);  // Campo de texto de tamanho 20
                gbc.gridx = 1;
                gbc.gridy = row;
                gbc.fill = GridBagConstraints.HORIZONTAL;
                painelDeInsercao.add(campoTexto, gbc); // Adiciona o JTextField
            }

            row++;  // Incrementa a linha para o próximo campo
        }

        // Adiciona um botão para realizar a inserção
        JButton btnInserir = new JButton("Inserir Dados");
        gbc.gridx = 0;
        gbc.gridy = row;
        gbc.gridwidth = 2;
        gbc.fill = GridBagConstraints.NONE;
        gbc.anchor = GridBagConstraints.CENTER;
        painelDeInsercao.add(btnInserir, gbc);

        // Evento para o botão de inserção
        btnInserir.addActionListener((ActionEvent e) -> {
            inserirDados(nomeTabela, painelDeInsercao); // Chama o método de inserção de dados
        });

        // Atualiza o layout do painel para garantir que os componentes sejam exibidos corretamente
        painelDeInsercao.revalidate();
        painelDeInsercao.repaint();
    }

    public boolean temRestricaoCheck(String nomeTabela, String coluna) {
        // Verifica se a coluna tem restrições CHECK com a cláusula 'IN'
        String query = "SELECT search_condition FROM user_constraints uc " +
                       "JOIN user_cons_columns ucc ON uc.constraint_name = ucc.constraint_name " +
                       "WHERE uc.constraint_type = 'C' AND ucc.table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND ucc.column_name = '" + coluna.toUpperCase() + "'";
        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);

            // Verifica todas as condições de CHECK para a coluna
            while (rs.next()) {
                String condition = rs.getString("search_condition");
                if (condition != null && condition.contains("IN")) {
                    return true;  // Se encontrar um 'IN', retorna true
                }
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao verificar restrição CHECK: " + e.getMessage());
        }
        return false; // Retorna false se não encontrar restrições com 'IN'
    }

    public String[] getValoresCheck(String nomeTabela, String coluna) {
        String query = "SELECT search_condition FROM user_constraints uc " +
                       "JOIN user_cons_columns ucc ON uc.constraint_name = ucc.constraint_name " +
                       "WHERE uc.constraint_type = 'C' AND ucc.table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND ucc.column_name = '" + coluna.toUpperCase() + "'";
        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);
            while (rs.next()) {
                String condition = rs.getString(1);

                // Verifica se a string "IN (" existe
                int start = condition.indexOf("IN");
                int end = condition.indexOf(")", start);
                if (start != -1 && end != -1) {
                    // Remove aspas simples e espaços, divide os valores
                    String valores = condition.substring(start + 4, end); 
                    return valores.replaceAll("'", "").split(",\\s*"); // Remove aspas e separa por vírgula
                }
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao obter valores do CHECK: " + e.getMessage());
        }
        return new String[0];
    }

    public boolean ehChaveEstrangeira(String nomeTabela, String coluna) {
        // Verifica se uma coluna é chave estrangeira
        String query = "SELECT COUNT(*) FROM user_cons_columns WHERE table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND column_name = '" + coluna.toUpperCase() + "' AND position IS NOT NULL";
        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao verificar chave estrangeira: " + e.getMessage());
        }
        return false;
    }

    public String[] getValoresChaveEstrangeira(String nomeTabela, String coluna) {
        String query = "SELECT ucc_referenced.table_name, ucc_referenced.column_name " +
                       "FROM user_cons_columns ucc " +
                       "JOIN user_constraints uc ON ucc.constraint_name = uc.constraint_name " +
                       "JOIN user_cons_columns ucc_referenced ON uc.r_constraint_name = ucc_referenced.constraint_name " +
                       "WHERE ucc.table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND ucc.column_name = '" + coluna.toUpperCase() + "' AND uc.constraint_type = 'R'";

        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);
            if (rs.next()) {
                String referencedTable = rs.getString(1);
                String referencedColumn = rs.getString(2);

                // Consulta os valores da tabela referenciada
                String queryFKValues = "SELECT DISTINCT " + referencedColumn + " FROM " + referencedTable;
                ResultSet rsFKValues = stmt.executeQuery(queryFKValues);

                ArrayList<String> valoresFK = new ArrayList<>();
                while (rsFKValues.next()) {
                    valoresFK.add(rsFKValues.getString(1));
                }

                return valoresFK.toArray(String[]::new);
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao obter valores de chave estrangeira: " + e.getMessage());
        }
        return new String[0];
    }

    public boolean ehChavePrimaria(String nomeTabela, String coluna) {
        // Verifica se a coluna é uma chave primária
        String query = "SELECT COUNT(*) FROM user_cons_columns ucc " +
                       "JOIN user_constraints uc ON ucc.constraint_name = uc.constraint_name " +
                       "WHERE uc.constraint_type = 'P' " +
                       "AND ucc.table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND ucc.column_name = '" + coluna.toUpperCase() + "'";
        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);
            if (rs.next()) {
                return rs.getInt(1) > 0; // Retorna true se for chave primária
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao verificar chave primária: " + e.getMessage());
        }
        return false;
    }
    
    public boolean ehColunaUnique(String nomeTabela, String coluna) {
        // Verifica se a coluna tem uma restrição UNIQUE
        String query = "SELECT COUNT(*) FROM user_cons_columns ucc " +
                       "JOIN user_constraints uc ON ucc.constraint_name = uc.constraint_name " +
                       "WHERE uc.constraint_type = 'U' " +  // 'U' para Unique
                       "AND ucc.table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND ucc.column_name = '" + coluna.toUpperCase() + "'";
        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);
            if (rs.next()) {
                return rs.getInt(1) > 0; // Retorna true se for UNIQUE
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao verificar coluna UNIQUE: " + e.getMessage());
        }
        return false;
    }
    
    public boolean ehColunaData(String nomeTabela, String coluna) {
        // Verifica se a coluna é do tipo DATE
        String query = "SELECT data_type FROM all_tab_columns WHERE table_name = '" + nomeTabela.toUpperCase() + "' " +
                       "AND column_name = '" + coluna.toUpperCase() + "'";
        try {
            stmt = connection.createStatement();
            rs = stmt.executeQuery(query);
            if (rs.next()) {
                return "DATE".equals(rs.getString(1));
            }
        } catch (SQLException e) {
            jtAreaDeStatus.setText("Erro ao verificar se a coluna é do tipo DATE: " + e.getMessage());
        }
        return false;
    }

    public String getDDLTables() {
        String[] tables = getTablesName();
        StringBuilder ddlFinal = new StringBuilder();

        for (String table : tables) {
            String ddl = "";
            String query = "SELECT DBMS_METADATA.GET_DDL('TABLE', '" + table.toUpperCase() + "') AS DDL FROM DUAL";

            try {
                stmt = connection.createStatement();
                rs = stmt.executeQuery(query);
                if (rs.next()) {
                    ddl = rs.getString("DDL");
                }
            } catch (SQLException e) {
                jtAreaDeStatus.setText("Erro ao obter o DDL da tabela: " + e.getMessage());
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                } catch (SQLException e) {
                    jtAreaDeStatus.setText("Erro ao fechar recursos: " + e.getMessage());
                }
            }
            ddlFinal.append(ddl).append("\n\n");
        }

        return ddlFinal.toString();
    }

}
