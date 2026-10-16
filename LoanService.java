package service;

import dao.LoanDAO;
import entity.Loan;

import java.util.List;

public class LoanService {
    private LoanDAO loanDAO = new LoanDAO();

    public List<Loan> getLoans(int userId) {
        return loanDAO.findByUserId(userId);
    }

    public List<Loan> getLoansByStatus(int userId, String status) {
        return loanDAO.findByUserIdAndStatus(userId, status);
    }

    public Loan getLoanById(int id, int userId) {
        return loanDAO.findById(id, userId);
    }

    public boolean addLoan(Loan loan) {
        loan.setStatus("unpaid");
        return loanDAO.addLoan(loan);
    }

    public boolean updateLoan(Loan loan) {
        return loanDAO.updateLoan(loan);
    }
    public boolean repayLoan(int id, int userId) {
        return loanDAO.updateStatus(id, userId, "paid");
    }

    public boolean deleteLoan(int id, int userId) {
        return loanDAO.deleteLoan(id, userId);
    }
}