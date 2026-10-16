package entity;

import java.math.BigDecimal;
import java.util.Date;

public class Loan {
    private Integer id;
    private Integer userId;
    private String type;
    private String person;
    private BigDecimal amount;
    private Date loanDate;
    private String status;
    private String remark;
    private Date createdAt;
    private Integer accountId;
    private Integer linkedTransactionId;
    private String accountName;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getPerson() { return person; }
    public void setPerson(String person) { this.person = person; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public Date getLoanDate() { return loanDate; }
    public void setLoanDate(Date loanDate) { this.loanDate = loanDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Integer getAccountId() { return accountId; }
    public void setAccountId(Integer accountId) { this.accountId = accountId; }
    public Integer getLinkedTransactionId() { return linkedTransactionId; }
    public void setLinkedTransactionId(Integer linkedTransactionId) { this.linkedTransactionId = linkedTransactionId; }
    public String getAccountName() { return accountName; }
    public void setAccountName(String accountName) { this.accountName = accountName; }
}