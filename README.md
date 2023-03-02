# Desafio golang - Imagem com até 2 MB

| Usuário | Repositório Dockerhub |
| ------- | --------------------- |
| wagneralmeida17 | docker pull wagneralmeida17/codeeducation:latest |


|   Salario   |  Emprestimo Pessoal  |    Emprestimo c/ garantia    | Consignado |
| :---:          |     :---:      |          :---:  |  :---:      |
| Salário <= 3000   | Sim     | Sim***    | Não |
| Salário >= 3000   | Sim     | Sim**     | Não |
| Salário >= 5000   | Sim     | Sim*      | Sim |
private readonly RequestDelegate _next;
        private readonly ILogger<LogginMiddleware> _logger;

        public LogginMiddleware(RequestDelegate next, ILogger<LogginMiddleware>  logger)
        {
            _next = next;
            _logger = logger;
            
        }

        public async Task Invoke(HttpContext context)
        {
            await LogRequest(context);
            await LogResponse(context);
        }

        private async Task LogRequest(HttpContext context) 
        {
            context.Request.EnableBuffering();
            using (var stream = new RecyclableMemoryStreamManager().GetStream())
            {
                await context.Request.Body.CopyToAsync(stream);
                _logger.LogInformation($"Http Request Information:{Environment.NewLine}" +
                           $"Schema:{context.Request.Scheme} " +
                           $"Host: {context.Request.Host} " +
                           $"Path: {context.Request.Path} " +
                           $"QueryString: {context.Request.QueryString} " +
                           $"Request Body: {ReadStreamInChunks(stream)}");
                context.Request.Body.Position = 0;
            }
        }

        private async Task LogResponse(HttpContext context) 
        {
            var originalBodyStream = context.Response.Body;
            using (var stream = new RecyclableMemoryStreamManager().GetStream())
            {
                context.Response.Body = stream;
                await _next(context);
                context.Response.Body.Seek(0, SeekOrigin.Begin);
                var text = await new StreamReader(context.Response.Body).ReadToEndAsync();
                context.Response.Body.Seek(0, SeekOrigin.Begin);
                _logger.LogInformation($"Http Response Information:{Environment.NewLine}" +
                                       $"Schema:{context.Request.Scheme} " +
                                       $"Host: {context.Request.Host} " +
                                       $"Path: {context.Request.Path} " +
                                       $"QueryString: {context.Request.QueryString} " +
                                       $"Response Body: {text}");
                await stream.CopyToAsync(originalBodyStream);
            }
        }

        private static string ReadStreamInChunks(Stream stream)
        {
            const int readChunkBufferLength = 4096;
            stream.Seek(0, SeekOrigin.Begin);
            using var textWriter = new StringWriter();
            using var reader = new StreamReader(stream);
            var readChunk = new char[readChunkBufferLength];
            int readChunkLength;
            do
            {
                readChunkLength = reader.ReadBlock(readChunk,
                                                   0,
                                                   readChunkBufferLength);
                textWriter.Write(readChunk, 0, readChunkLength);
            } while (readChunkLength > 0);
            return textWriter.ToString();
        }
