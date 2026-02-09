import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  console.log("📨 Função send-email chamada");
  
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    console.log("✅ Body recebido");

    const {
      emails,
      pdfBase64,
      pdfName,
      numeroEmenda,
      parlamentar,
      programa,
      valor,
    } = body;

    console.log("🔍 Validando dados...");
    
    if (!emails || !Array.isArray(emails) || emails.length === 0) {
      throw new Error("emails é obrigatório e deve ser um array não vazio");
    }

    if (!pdfBase64) {
      throw new Error("pdfBase64 é obrigatório");
    }

    if (!pdfName) {
      throw new Error("pdfName é obrigatório");
    }

    // Validar emails
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    for (const email of emails) {
      if (!emailRegex.test(email)) {
        throw new Error(`Email inválido: ${email}`);
      }
    }

    console.log("✅ Dados validados com sucesso");

    // ======== GMAIL SMTP CONFIGURATION ========
    // SEM CADASTRO! Use sua conta Gmail existente
    // Instruções em: GMAIL_SMTP_SETUP.md
    
    const GMAIL_USERNAME = Deno.env.get("GMAIL_USERNAME");
    const GMAIL_APP_PASSWORD = Deno.env.get("GMAIL_APP_PASSWORD");

    if (!GMAIL_USERNAME) {
      throw new Error("GMAIL_USERNAME não configurada. Veja GMAIL_SMTP_SETUP.md");
    }

    if (!GMAIL_APP_PASSWORD) {
      throw new Error("GMAIL_APP_PASSWORD não configurada. Veja GMAIL_SMTP_SETUP.md");
    }

    console.log(`📧 Conectando ao Gmail SMTP...`);

    // Criar cliente SMTP
    const client = new SmtpClient({
      connection: {
        hostname: "smtp.gmail.com",
        port: 465,
        tls: true,
      },
      auth: {
        username: GMAIL_USERNAME,
        password: GMAIL_APP_PASSWORD,
      }
    });

    console.log("🔐 Autenticando no Gmail...");
    await client.connect();
    console.log("✅ Conectado ao Gmail SMTP com sucesso");

    // Preparar email em HTML
    const htmlContent = `
      <html>
        <body style="font-family: Arial, sans-serif; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; padding: 20px;">
            <h2 style="color: #C41E3A; border-bottom: 3px solid #C41E3A; padding-bottom: 10px;">
              ✅ Plano de Trabalho Salvo com Sucesso!
            </h2>
            <p>Seu plano de trabalho foi registrado no sistema da Secretaria de Estado da Saúde de São Paulo.</p>
            <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
              <tr>
                <td style="padding: 10px; background: #f5f5f5; font-weight: bold; width: 150px;">Parlamentar:</td>
                <td style="padding: 10px;">${parlamentar || "N/A"}</td>
              </tr>
              <tr>
                <td style="padding: 10px; background: #f5f5f5; font-weight: bold;">Nº Emenda:</td>
                <td style="padding: 10px;">${numeroEmenda || "N/A"}</td>
              </tr>
              <tr>
                <td style="padding: 10px; background: #f5f5f5; font-weight: bold;">Programa:</td>
                <td style="padding: 10px;">${programa || "N/A"}</td>
              </tr>
              <tr>
                <td style="padding: 10px; background: #f5f5f5; font-weight: bold;">Valor:</td>
                <td style="padding: 10px; color: #C41E3A; font-weight: bold;">R$ ${valor || "N/A"}</td>
              </tr>
            </table>
            <p style="background: #f0f0f0; padding: 15px; border-radius: 4px; border-left: 4px solid #C41E3A;">
              <strong>📎 Arquivo em Anexo:</strong> ${pdfName}
            </p>
            <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
            <p style="margin-top: 20px; color: #666; font-size: 12px;">
              <strong>Secretaria de Estado da Saúde de São Paulo</strong><br/>
              Emendas Parlamentares 2026<br/>
              ${new Date().toLocaleDateString('pt-BR')}
            </p>
          </div>
        </body>
      </html>
    `;

    // Converter PDF base64 para buffer
    const pdfBuffer = new Uint8Array(atob(pdfBase64).split('').map(c => c.charCodeAt(0)));

    console.log(`📤 Enviando para ${emails.length} destinatário(s)...`);

    // Enviar email para cada destinatário
    for (const email of emails) {
      console.log(`  ├─ Enviando para: ${email}`);
      
      await client.send({
        from: GMAIL_USERNAME,
        to: email,
        subject: `Plano de Trabalho 2026 - Emenda ${numeroEmenda}`,
        html: htmlContent,
        attachments: [
          {
            filename: pdfName,
            content: pdfBuffer,
            contentType: "application/pdf",
          }
        ]
      });
      
      console.log(`  ✅ Enviado para: ${email}`);
    }

    console.log("✅ Finalizando conexão com Gmail...");
    await client.close();
    console.log("✅ Email enviado com SUCESSO!");
    console.log("✅ Emails enviados para:", emails.join(", "));

    return new Response(
      JSON.stringify({
        success: true,
        message: "Email enviado com sucesso",
        emails: emails,
      }),
      { 
        status: 202,
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      }
    );

  } catch (error: unknown) {
    console.error("❌ ERRO NA FUNÇÃO:", error);

    const errorMessage =
      error instanceof Error ? error.message : "Erro desconhecido";

    console.error("❌ Mensagem de erro:", errorMessage);

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
