def payments [] {
  let processor_1 = (http get -H {X-Rinha-Token: '123'} http://localhost:8001/admin/payments-summary)
  let processor_2 = (http get -H {X-Rinha-Token: '123'} http://localhost:8002/admin/payments-summary)
  let backend  = (http get http://localhost:9999/payments-summary)

  [
    {processor: "default", totalRequests: $processor_1.totalRequests, totalAmount: $processor_1.totalAmount, from: "processor"}, 

    {processor: "default", totalRequests: $backend.default.totalRequests, totalAmount: $backend.default.totalAmount, from: "db"}, 
    {processor: "fallback", totalRequests: $processor_2.totalRequests, totalAmount: $processor_2.totalAmount, from: "processor"}, 
    {processor: "fallback", totalRequests: $backend.fallback.totalRequests, totalAmount: $backend.fallback.totalAmount, from: "db"} 
  ] | table
}
