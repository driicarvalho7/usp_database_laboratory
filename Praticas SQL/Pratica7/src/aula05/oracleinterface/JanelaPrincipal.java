/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package aula05.oracleinterface;

import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.table.DefaultTableModel;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;
import javax.swing.Timer;

/**
 *
 * @author junio
 */
public class JanelaPrincipal {

    JFrame j;
    JPanel pPainelDeCima;
    JPanel pPainelDeBaixo;
    JComboBox jc;
    JTextArea jtAreaDeStatus;
    JTextArea taDDLSchema;
    JTabbedPane tabbedPane;
    JPanel pPainelDeExibicaoDeDados;
    JTable jt;
    JPanel pPainelDeInsecaoDeDados;
    JPanel pPainelDoDDLSchema;
    DBFuncionalidades bd;
    private JButton btnExportarCSV;
    private JButton btnExibirDDL;
    String nomeTabela = "";
    private JDialog loadingDialog;
    private JLabel loadingLabel;
    private Timer timer;

    public void ExibeJanelaPrincipal() {
        /*Janela*/
        j = new JFrame("ICMC-USP - LAB BD");
        j.setSize(700, 500);
        j.setLayout(new BorderLayout());
        j.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        j.setLocationRelativeTo(null);

        /*Painel da parte superior (north) - com combobox e outras informações*/
        pPainelDeCima = new JPanel();
        j.add(pPainelDeCima, BorderLayout.NORTH);
        jc = new JComboBox();
        jc.addItem("- SELECIONAR -");
        pPainelDeCima.add(jc);
        
        // No método ExibeJanelaPrincipal, dentro do painel superior:
        btnExportarCSV = new JButton("Exporta CSV MSExcel");
        pPainelDeCima.add(btnExportarCSV);

        /*Painel da parte inferior (south) - com área de status*/
        pPainelDeBaixo = new JPanel();
        j.add(pPainelDeBaixo, BorderLayout.SOUTH);
        jtAreaDeStatus = new JTextArea();
        jtAreaDeStatus.setText("Aqui é sua área de status");
        pPainelDeBaixo.add(jtAreaDeStatus);

        /*Painel tabulado na parte central (CENTER)*/
        tabbedPane = new JTabbedPane();
        j.add(tabbedPane, BorderLayout.CENTER);

        /*Tab de exibicao*/
        pPainelDeExibicaoDeDados = new JPanel();
        pPainelDeExibicaoDeDados.setLayout(new GridLayout(1, 1));
        tabbedPane.add(pPainelDeExibicaoDeDados, "Exibição");
        /* Table de exibição */
        int nColunas = 1;
        String colunas[] = {};
        String dados[][] = {};

        // Crie a JTable com DefaultTableModel
        DefaultTableModel model = new DefaultTableModel(dados, colunas);
        jt = new JTable(model);
        JScrollPane jsp = new JScrollPane(jt);
        pPainelDeExibicaoDeDados.add(jsp);

        /*Tab de inserção*/
        pPainelDeInsecaoDeDados = new JPanel();
        pPainelDeInsecaoDeDados.setLayout(new GridLayout(nColunas, 2));
        tabbedPane.add(pPainelDeInsecaoDeDados, "Inserção");

        /*Tab de DDL Schema*/
        pPainelDoDDLSchema = new JPanel();
        pPainelDoDDLSchema.setLayout(new BorderLayout());
        taDDLSchema = new JTextArea();
        taDDLSchema.setEditable(false);
        JScrollPane scrollDDL = new JScrollPane(taDDLSchema);
        pPainelDoDDLSchema.add(scrollDDL, BorderLayout.CENTER);
        btnExibirDDL = new JButton("Exibir DDL do Schema");
        pPainelDoDDLSchema.add(btnExibirDDL, BorderLayout.SOUTH);
        tabbedPane.add(pPainelDoDDLSchema, "DDL do Schema");
        
        
        j.setVisible(true);

        bd = new DBFuncionalidades(jtAreaDeStatus);
        if (bd.conectar())
            bd.pegarNomesDeTabelas(jc);
        
        this.DefineEventos();        
    }
    
    // Método para mostrar a tela de carregamento
    private void showLoadingScreen() {
        loadingDialog = new JDialog(j, "", true); // Cria um diálogo modal
        loadingDialog.setSize(200, 100);
        loadingDialog.setLocationRelativeTo(j); // Centraliza na janela principal

        loadingLabel = new JLabel("Carregando", JLabel.CENTER); // Cria o JLabel com o texto inicial
        loadingDialog.add(loadingLabel);
        loadingDialog.setDefaultCloseOperation(JDialog.DO_NOTHING_ON_CLOSE);

        // Timer para atualizar o JLabel a cada segundo
        timer = new Timer(500, e -> {
            String currentText = loadingLabel.getText();
            if (currentText.equals("Carregando")) {
                loadingLabel.setText("Carregando.");
            } else if (currentText.equals("Carregando.")) {
                loadingLabel.setText("Carregando..");
            } else if (currentText.equals("Carregando..")) {
                loadingLabel.setText("Carregando...");
            } else {
                loadingLabel.setText("Carregando");
            }
        });
        timer.start(); // Inicia o timer

        // Exibe o diálogo em uma thread separada para não bloquear a UI
        SwingUtilities.invokeLater(() -> loadingDialog.setVisible(true));
    }

    // Método para esconder a tela de carregamento
    private void hideLoadingScreen() {
        // Para o timer e esconde a tela de carregamento
        if (timer != null) {
            timer.stop(); // Para o timer para interromper a animação
        }
        loadingDialog.setVisible(false);
        loadingDialog.dispose();
    }

    private void DefineEventos() {
        // Evento do dropdown de seleção de tabelas
        jc.addActionListener((ActionEvent e) -> {
            // Exibe a tela de carregamento
            showLoadingScreen();

            new Thread(() -> {
                try {
                    JComboBox jcTemp = (JComboBox) e.getSource();
                    nomeTabela = (String) jcTemp.getSelectedItem();
                    jtAreaDeStatus.setText(nomeTabela);
                    bd.exibeDados(jt, nomeTabela);
                    bd.prepararInsercaoDeDados(pPainelDeInsecaoDeDados, nomeTabela);
                } finally {
                    hideLoadingScreen();
                }
            }).start();
        });

        // Evento para o botão de exportação CSV        
        btnExportarCSV.addActionListener((ActionEvent e) -> {
            if (nomeTabela != null && !"".equals(nomeTabela)) {
                // Exibe a tela de carregamento
                showLoadingScreen();

                new Thread(() -> {
                    try {
                        bd.exportarCsv(nomeTabela);
                        jtAreaDeStatus.setText("Exportação concluída.");
                    } finally {
                        hideLoadingScreen();
                    }
                }).start();
            } else {
                jtAreaDeStatus.setText("Nenhuma tabela selecionada.");
            }
        });
        
        btnExibirDDL.addActionListener((ActionEvent e) -> {
            // Exibe a tela de carregamento
            showLoadingScreen();

            new Thread(() -> {
                try {
                    String ddl = bd.getDDLTables();
                    taDDLSchema.setText(ddl);  // Exibe o DDL no JTextArea
                } finally {
                    // Fecha a tela de carregamento após o processo
                    hideLoadingScreen();
                }
            }).start();
        });
    }
}
