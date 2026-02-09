import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

serve(async (req) => {
  console.log('🚀 Função manage-users chamada');
  
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    console.log('✅ Preflight request');
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verificar método
    if (req.method !== "POST") {
      console.log('❌ Método não permitido:', req.method);
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: corsHeaders,
      });
    }

    const body = await req.json();
    const { action, userId, newPassword } = body;

    console.log('📋 Ação recebida:', { action, userId });

    if (action === "change-password") {
      console.log('🔐 Alterando senha do usuário:', userId);
      
      if (!newPassword || newPassword.length < 6) {
        console.log('❌ Senha muito curta');
        return new Response(
          JSON.stringify({ error: "Password must be at least 6 characters" }),
          { 
            status: 400,
            headers: corsHeaders,
          }
        );
      }

      const { error } = await supabase.auth.admin.updateUserById(userId, {
        password: newPassword,
      });

      if (error) {
        console.log('❌ Erro ao alterar senha:', error);
        return new Response(JSON.stringify({ error: error.message }), {
          status: 400,
          headers: corsHeaders,
        });
      }

      console.log('✅ Senha alterada com sucesso');
      return new Response(JSON.stringify({ success: true, message: "Password changed successfully" }), { 
        status: 200,
        headers: corsHeaders,
      });
    }

    if (action === "delete-user") {
      console.log('🗑️ Deletando usuário:', userId);
      
      // 1. Deletar do auth
      const { error: authError } = await supabase.auth.admin.deleteUser(
        userId
      );

      if (authError) {
        console.log('❌ Erro ao deletar do auth:', authError);
        return new Response(JSON.stringify({ error: authError.message }), {
          status: 400,
          headers: corsHeaders,
        });
      }

      console.log('✅ Usuário deletado do auth');

      // 2. Deletar do profiles
      const { error: profileError } = await supabase
        .from("profiles")
        .delete()
        .eq("id", userId);

      if (profileError) {
        console.log('⚠️ Erro ao deletar do profiles:', profileError);
        // Não retorna erro aqui pois o usuário já foi deletado do auth
      }

      console.log('✅ Usuário deletado completamente');
      return new Response(JSON.stringify({ success: true, message: "User deleted successfully" }), { 
        status: 200,
        headers: corsHeaders,
      });
    }

    console.log('❌ Ação desconhecida:', action);
    return new Response(JSON.stringify({ error: "Unknown action" }), {
      status: 400,
      headers: corsHeaders,
    });
  } catch (error: any) {
    console.log('❌ ERRO NA FUNÇÃO:', error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: corsHeaders,
    });
  }
});
