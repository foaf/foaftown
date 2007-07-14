package com.xmlns.foaftown;

import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.Iterator;
import java.util.Vector;

import javax.swing.JFrame;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.RDFNode;

/**
 * Quick and dirty SPARQL results viewer. Cribbed from related code 
 * in Twinkle
 * 
 * Use it as follows:
 * 
 * <code>
 * ResultViewer viewer = new ResultsViewer("Query Results, Packet=" + package.getPacketID());
 * viewer.show();
 * viewer.display(results);
 * </code>
 * 
 * Closing the window should dispose of it correctly
 * 
 * @author Leigh Dodds
 */
public class ResultsViewer extends JFrame 
{
    private JTable _resultsTable;
    
	public ResultsViewer(String title)
	{
		super(title);
        _resultsTable = new JTable();		
        getContentPane().add(_resultsTable);
        setDefaultWindowSize();
        addWindowListener();
	}
	
    private void addWindowListener()
    {
        addWindowListener(new WindowAdapter() {
        	public void windowClosing(WindowEvent e) 
        	{        		
        		//System.exit(0);
        		e.getWindow().hide();
        		e.getWindow().dispose();
			}
    	});
    }
    
    /**
     * 
     */
    private void setDefaultWindowSize()
    {
        int inset = 75;
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        setBounds(inset, inset, 
                  screenSize.width - inset*2, 
                  screenSize.height-inset*2);
    }
    
    public void display(ResultSet results)
    {
        DefaultTableModel tableModel = new DefaultTableModel(getData(results), getColumns(results));
        _resultsTable.setModel(tableModel);
        _resultsTable.repaint();                  
    }

    private Vector getData(ResultSet data)
    {
        Vector results = new Vector();
        for (; data.hasNext(); )
        {
            QuerySolution qs = data.nextSolution();
            results.add( getRowData(data, qs) );
        }
        return results;
    }
    
    private Vector getRowData(ResultSet results, QuerySolution qs)
    {
        Vector row = new Vector();
        for (Iterator iter = results.getResultVars().iterator() ; iter.hasNext() ; )
        {
            String var = (String)iter.next();
            row.add( getValueAsString(qs, var) );
        }
        return row;
    }
    
    private String getValueAsString(QuerySolution qs, String var)
    {
        RDFNode result = qs.get(var);
        if (result == null)
        {
            return "";
        }
        return result.toString();
    }
    private Vector getColumns(ResultSet results)
    {
        Vector cols = new Vector();
        cols.addAll(results.getResultVars());
        return cols;
    }
    
}
