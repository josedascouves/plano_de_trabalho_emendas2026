import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { planoId, emails, pdfBase64, pdfName } = await req.json();

    console.log(`📧 Enviando PDF ${pdfName} para ${emails.length} email(s)...`);

    // Validação básica
    if (!planoId || !emails || !Array.isArray(emails) || emails.length === 0) {
      throw new Error("Dados inválidos: planoId, emails são obrigatórios");
    }

    // TODO: Implementar envio de email
    // Opções:
    // 1. Usar Resend (resend.com) - mais fácil
    // 2. Usar SendGrid
    // 3. Usar Mailgun
    // 4. Usar PostMark (integrado com Supabase)

    // Por enquanto, retornando sucesso simulado
    console.log(`✅ Preparação para enviar para: ${emails.join(", ")}`);

    return new Response(
      JSON.stringify({
        success: true,
        message: `Email seria enviado para: ${emails.join(", ")}`,
        planoId,
        emailsEnviados: emails.length,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      200
    );
  } catch (error) {
    console.error("❌ Erro ao processar requisição:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Erro desconhecido",
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      400
    );
  }
});
